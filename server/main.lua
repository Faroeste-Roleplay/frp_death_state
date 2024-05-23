local Tunnel = module("frp_lib", "lib/Tunnel")
local Proxy = module("frp_lib", "lib/Proxy")

API = Proxy.getInterface("API")
Inventory = Proxy.getInterface("inventory")
cAPI = Tunnel.getInterface("API")


RegisterCommand("revive", function(source, args)
    local playerId = args[1]
    print(" playerId :: ", playerId)

    TriggerEvent('deathfsm.fire', playerId, 'ReviveByCommand')
end)

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

        ResetPlayerPotentMedicineStats(Character)

        if previousStateType == eStateType.Respawning  then
            --[[ O player respawnou! ]]

            exports.ox_inventory:ClearInventory(playerId)
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
            local CharacterKiller = UserKiller:GetCharacter()

            if CharacterKiller then

                logMessage = logMessage .. (' | "%s" está envolvido'):format(CharacterKiller:GetFullName())
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

        ResetPlayerPotentMedicineStats(Character)
    end
end)

RegisterNetEvent("FRP:onCharacterLoaded", function(User, character_id)
    local Character = User:GetCharacter()
    local playerId = User:GetSource()

    LoadPlayerState(playerId, Character)
end)

-- RegisterNetEvent('redem:net.playerLoadedIntoWorld', function()
--     local playerId = source

--     local User = API.GetUserFromSource(playerId)
--     local Character = User:GetCharacter()

--     LoadPlayerState(playerId, Character)
-- end)

function GetPlayerStateType(Character)
    return Character:GetSessionVar('deathfsm:stateType') or eStateType.Alive
end

exports('itemTonic', function(event, item, inventory, slot, data)

    if event == 'usingItem' then
        local playerId = inventory.id
        local User   = API.GetUserFromSource(playerId)
        local Character = User:GetCharacter()

        local playerStateType = GetPlayerStateType(Character)

        local stateLocalized = nil

        if playerStateType == eStateType.Incapacitated then
            stateLocalized = 'incapacitado'
        elseif playerStateType == eStateType.Wounded then
            stateLocalized = 'machucado'
        elseif playerStateType == eStateType.Dead then
            stateLocalized = 'morto'
        end
        
        if stateLocalized then
            cAPI.Notify(playerId, "error", ('Você não pode usar items de cura enquanto estiver %s!'):format(stateLocalized), 5000)
            return false
        end

        return true
    end

    return true
end)

exports('reviverItem', function(event, item, inventory, slot, data)
    
    if event == 'buying' then
        return true
    end

    local reviverPlayerId = inventory.id

    local User   = API.GetUserFromSource(reviverPlayerId)
    local reviverCharacter = User:GetCharacter()

    if event == 'usingItem' then

        local reviverPlayerStateType = GetPlayerStateType(reviverCharacter)

        local isSelfRevive = reviverPlayerStateType == eStateType.Incapacitated

        local revivedPlayerId = isSelfRevive and reviverPlayerId or nil

        if not isSelfRevive then
            local reviverPlayerPos = GetEntityCoords(GetPlayerPed(reviverPlayerId))
    
            local nearbyIncapacitatedPlayers = { }

            local p = promise.new()
    
            local players = API.GetUsers()
            for userId, User in pairs(players) do
                local playerId = User:GetSource()
                local Character = User:GetCharacter()
    
                if playerId ~= reviverPlayerId then
    
                    local playerPedId = GetPlayerPed(playerId)
    
                    if playerPedId ~= 0 then
    
                        local isIncapacitated = GetPlayerStateType(Character) == eStateType.Incapacitated

                        if isIncapacitated then
    
                            table.insert(nearbyIncapacitatedPlayers,
                            {
                                playerId = playerId,
                                distanceToReviverPlayer = #(GetEntityCoords(playerPedId) - reviverPlayerPos)
                            })
                        end
                    end
                end
            end

            p:resolve()

            Citizen.Await(p)
    
            table.sort(nearbyIncapacitatedPlayers, function(a, b)
                return a.distanceToReviverPlayer < b.distanceToReviverPlayer
            end)
    
            local nearestIncapacitatedPlayer = nearbyIncapacitatedPlayers[1]
    
            if not nearestIncapacitatedPlayer then
                return false -- error('Ninguem por perto!')
            end

            if nearestIncapacitatedPlayer.distanceToReviverPlayer > 1.5 then
                return false -- error('Player está longe demais!')
            end

            if IsPlayerMidInteraction(nearestIncapacitatedPlayer.playerId) then
                return false -- Esse jogador já está sendo revivido!
            end

            revivedPlayerId = nearestIncapacitatedPlayer.playerId
        end

        if not revivedPlayerId then
            return false -- error('ninguem para ser revivido')
        end

        SetPlayerIsBeingRevived(revivedPlayerId, true)

        reviverCharacter:SetSessionVar('playerIdBeingRevivedByMe', revivedPlayerId)

        return true
    end

    if event == 'usedItem' then

        local playerIdBeingRevived = reviverCharacter:GetSessionVar('playerIdBeingRevivedByMe')

        if not playerIdBeingRevived then
            return false
        end

        SetPlayerIsBeingRevived(playerIdBeingRevived, false)

        reviverCharacter:SetSessionVar('playerIdBeingRevivedByMe', nil)

        TriggerClientEvent('net.deathfsm.fire', playerIdBeingRevived, eTriggerType.Revive)

        return true
    end

    return false
end)