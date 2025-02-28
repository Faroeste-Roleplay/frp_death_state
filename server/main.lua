local Tunnel = module("frp_lib", "lib/Tunnel")
local Proxy = module("frp_lib", "lib/Proxy")

API = Proxy.getInterface("API")
Inventory = Proxy.getInterface("inventory")
cAPI = Tunnel.getInterface("API")

TransportManager = Proxy.getInterface("transport")

Server = {}

Proxy.addInterface("death_state", Server)

AddEventHandler('deathfsm.fire', function(playerId, triggerTypeName)
    local triggerType = eTriggerType[triggerTypeName]

    assert(triggerType, ('eTriggerType (%s) é invalido'):format(triggerTypeName) )

    TriggerClientEvent('net.deathfsm.fire', playerId, triggerType)
end)

RegisterNetEvent('net.deathfsm.stateChanged', function(stateType, metadata)
    local scope = log:scope()

    local playerId = source

    assert(type(stateType) == 'number')

    assert(eStateType[stateType])

    local User = API.GetUserFromSource(playerId)
    local Character = User:GetCharacter()

    assert(Character)

    scope:setUser(Character)

    local characterId = Character:GetId()

    assert(characterId)

    local previousStateType = GetPlayerStateType(Character)

    Character:SetSessionVar('deathfsm:stateType', stateType)

    MySQL.update.await('UPDATE `character` SET `deathState` = ? WHERE `id` = ?', { stateType + 1 --[[ A enum no banco de dados começa em '1' ]], characterId })

    if stateType == eStateType.Alive then

        ResetPlayerPotentMedicineStats(playerId)

        if previousStateType == eStateType.Respawning  then
            --[[ O player respawnou! ]]

            -- exports.ox_inventory:ClearInventory(playerId)

            local playerMoney = exports.ox_inventory:GetItem( playerId, "money", nil, true )

            if playerMoney > 0 then
                exports.ox_inventory:RemoveItem( playerId, "money", playerMoney )
            end
        end
    end

    if Character:GetSessionVar('deathfsm:noLogging') then
        Character:SetSessionVar('deathfsm:noLogging', false)
        return
    end

    local logMessage = ('"%s" agora está %s'):format(Character:GetFullName(), eStateTypeLocale[stateType])

    if metadata then
        local weaponUsedName, playerServerIdKiller in metadata

        if weaponUsedName then
            logMessage = logMessage .. (' | "%s"'):format(weaponUsedName)
        end

        if playerServerIdKiller then

            local UserKiller = API.GetUserFromSource(playerServerIdKiller)
            if UserKiller then
                local CharacterKiller = UserKiller:GetCharacter()

                if CharacterKiller then

                    logMessage = logMessage .. (' | "%s" está envolvido'):format(CharacterKiller:GetFullName())
                end
            end
        end
    end

    log:captureMessage(logMessage, scope)
end)


function LoadPlayerState(playerId, Character)
    local characterId = Character:GetId()

    local stateTypeName = MySQL.scalar.await('SELECT `deathState` FROM `character` WHERE id = ?', { characterId })

    assert(stateTypeName, 'Que merda aconteceu?')

    local stateType = eStateType[stateTypeName]

    if stateType == eStateType.Alive then
        --[[ A gente não faz nada caso o estado do player no banco de dados seja 'Alive' já que o padrão já é 'Alive' ]]
        return
    end

    local triggerType = nil

    if     stateType == eStateType.Incapacitated then
        triggerType = eTriggerType.Incapacitate

    elseif stateType == eStateType.Wounded then
        triggerType = eTriggerType.Wound

    elseif stateType == eStateType.Dead then
        triggerType = eTriggerType.Die
        
    elseif stateType == eStateType.Respawning then
        triggerType = eTriggerType.Respawn
    end

    assert(triggerType)

    TriggerClientEvent('net.deathfsm.fire', playerId, triggerType)

    Character:SetSessionVar('deathfsm:noLogging', true)
end


RegisterNetEvent('FRP:postCharacterInitialization', function() 
    local playerId = source

    local User = API.GetUserFromSource( playerId )

    local playerId = User:GetSource()
    local Character = User:GetCharacter()

    LoadPlayerState( playerId, Character )
end)

CreateThread(function()

    --[[ Aguardar o client fazer download do script e inicializar. ]]
    Wait(2000)

    local players = API.GetUsers()
    for userId, User in pairs(players) do
        local playerId = User:GetSource()
        local Character = User:GetCharacter()
        LoadPlayerState(playerId, Character)

        SetPlayerIsBeingRevived(playerId, nil)
        SetPlayerIsRevivingPlayer(playerId, nil)

        SetPlayerIsBeingAppliedPotentMedicine(playerId, nil)
        SetPlayerIsApplyingPotentMedicine(playerId, nil)

        ResetPlayerPotentMedicineStats(playerId)
    end
end)


function GetPlayerStateType(Character)
    return Character:GetSessionVar('deathfsm:stateType') or eStateType.Alive
end

RegisterNetEvent('net.game.itemReviverUsed', function(revivedGameobjectNetworkId)
    local playerId = source

	local numRevivers = Inventory.GetItem(playerId, 'tonic_horse_revive', nil, true)

	local gameobjectId = NetworkGetEntityFromNetworkId(revivedGameobjectNetworkId)

	if numRevivers <= 0 then
		-- SetEntityHealth(gameobjectId, 0)

		-- #TODO: Notificar o player.

		Server.SetEntityGamestate(gameobjectId, 'Dead')

		return
	end

	Inventory.RemoveItem(playerId, 'tonic_horse_revive', 1)

	Server.SetEntityGamestate(gameobjectId, 'Alive')
end)


function Server.SetEntityGamestate( gameobjectId, stateName )
    local state = eStateType[stateName]
    
    print(" SetEntityGamestate  :: ", gameobjectId, stateName)

    assert(state, ("State(%s) não é válido!"):format(stateName))

    if IsPedAPlayer( gameobjectId ) then
        local playerId = NetworkGetEntityOwner(gameobjectId)
        local User = API.GetUserFromSource( playerId )

        if not User then
            return
        end

        local trigger = nil

        if state == eStateType.Alive then
            trigger = eTriggerType.Revive
        elseif state == eStateType.Dead then
            trigger = eTriggerType.Die
        end

        if trigger then
            TriggerClientEvent('net.deathfsm.fire', playerId, trigger)
        end
    else
        local transport = TransportManager.GetTransportByEntity(gameobjectId)

        print(" transport :: ", transport)

        if not transport then
            return
        end

        TransportManager.SetTransportDeathState(transport.transportId, state)
        transport:SetStatebagKey("transport:change_deathstate", state, true)
    end
end
