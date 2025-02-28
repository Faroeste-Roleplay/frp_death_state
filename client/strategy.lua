gLastIncapacitationFromDamageAt = nil

CreateThread(function()
    Wait(2000)

    -- local function updateMetadata()
    --     local pedIdKiller = culpritIndex
    --     local playerIdKiller = NetworkGetPlayerIndexFromPed(pedIdKiller)
    
    --     local weaponUsed = damageType
    
    --     local weaponUsedName = Citizen.InvokeNative(0x89CF5FF3D363311E, weaponUsed, Citizen.ResultAsString())
    --     local weaponUsedNameHash = GetHashKey(weaponUsedName)
    --     local weaponUsedNameLocalized = GetLabelTextByHash(weaponUsedNameHash)

    --     setDeathStateChangeMetadata({
    --         weaponUsedName = weaponUsedNameLocalized == '' and weaponUsedName or weaponUsedNameLocalized,
    --         playerServerIdKiller = GetPlayerServerId(playerIdKiller),
    --     })
    -- end


    while true do 
        local playerPed = PlayerPedId()
        local currentStateType = GetCurrentStateType()
        
        local now = GetGameTimer()

        if N_0xb655db7582aec805(playerPed) ~= 0 and currentStateType ~= eStateType.Incapacitated then

            if currentStateType == eStateType.Alive or currentStateType == eStateType.Wounded then
    
                if gLastIncapacitationFromDamageAt and now - gLastIncapacitationFromDamageAt < INCAPACITATION_MIN_TIME_BETWEEN_INCAPACTION_OR_INSTA_KILL then
                    die()
                else
                    gLastIncapacitationFromDamageAt = now
    
                    -- updateMetadata()
    
                    incapacitate()
                end
            end
        end

        if IsPlayerDead(PlayerId()) and  currentStateType ~= eStateType.Dead then
            die()
        end

        Wait(200)
    end
end)

local gCurrentHeight = 0

AddEventHandler('gameEvent', function(eventName, eventData)

    if eventName == 'EVENT_CARRIABLE_UPDATE_CARRY_STATE' then
        -- local CarriableEntityId = eventData.CarriableEntityId

        -- print(" EVENT_CARRIABLE_UPDATE_CARRY_STATE :: ", CarriableEntityId, PlayerPedId())
        
        -- if CarriableEntityId == PlayerPedId() then
        --     cAPI.SetPlayerScale()
        -- end
    elseif eventName == "EVENT_NETWORK_DAMAGE_ENTITY" then
        
    elseif eventName == "EVENT_NETWORK_INCAPACITATED_ENTITY" then
        
    elseif eventName == "EVENT_ENTITY_DAMAGED" then
        local playerPed = eventData.damagedEntityId
        
        if N_0xb655db7582aec805(playerPed) ~= 0 then
            
        end

    elseif eventName == "EVENT_INCAPACITATED" then
        
    end
end)

AddEventHandler('game.networkDamageEntity', function(event)

    if not gMachine then
        return
    end

    local victimIndex, victimIncapacitated, victimBleedout, victimDestroyed, damageType, culpritIndex in event

    local isLocalPed = victimIndex == PlayerPedId()

    if not isLocalPed then
        return
    end

    if LocalPlayer.state['loadingIntoWorld'] == true then
        return
    end

    local function updateMetadata()
        local pedIdKiller = culpritIndex
        local playerIdKiller = NetworkGetPlayerIndexFromPed(pedIdKiller)
    
        local weaponUsed = damageType
    
        local weaponUsedName = Citizen.InvokeNative(0x89CF5FF3D363311E, weaponUsed, Citizen.ResultAsString())
        local weaponUsedNameHash = GetHashKey(weaponUsedName)
        local weaponUsedNameLocalized = GetLabelTextByHash(weaponUsedNameHash)

        setDeathStateChangeMetadata({
            weaponUsedName = weaponUsedNameLocalized == '' and weaponUsedName or weaponUsedNameLocalized,
            playerServerIdKiller = GetPlayerServerId(playerIdKiller),
        })
    end

    if victimDestroyed then

        updateMetadata()

        die()

        return
    end

    if victimIncapacitated then
        
        local now = GetGameTimer()

        local currentStateType = GetCurrentStateType() 

        if currentStateType == eStateType.Alive or currentStateType == eStateType.Wounded then

            if gLastIncapacitationFromDamageAt and now - gLastIncapacitationFromDamageAt < INCAPACITATION_MIN_TIME_BETWEEN_INCAPACTION_OR_INSTA_KILL then
                die()
            else
                gLastIncapacitationFromDamageAt = now

                updateMetadata()

                incapacitate()
            end
        end

        return
    end
end)