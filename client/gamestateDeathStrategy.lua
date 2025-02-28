function HandleNetworkEntityDamage(event)

    local victimIndex = tonumber(event.victimIndex)
    local damage = tonumber(event.damage)
    local victimDestroyed = event.victimDestroyed
    local victimIncapacitated = event.victimIncapacitated

    local isLocalPed = victimIndex == PlayerPedId()
    local transport = TransportManager.GetTransportFromEntityId(victimIndex)
    
    local isTransport = transport ~= nil

    if not isLocalPed and not isTransport then
        return
    end
    
    if victimDestroyed then
        if not isLocalPed then
            -- TransportServer.SetTransportState( transport.transportId, eStateType.Dead)
            transport:SetState(eStateType.Dead)
        end
        return
    end

    if victimIncapacitated then
        if not isLocalPed then
            transport:SetState(eStateType.Incapacitated)
        end
        
        return
    end
end

function ProcessEventRevivedEntity(event)
    local revivedEntityId = event.victimEntityId
    local reviverEntityId = event.reviverEntityId

    local localPedId = PlayerPedId()

    if reviverEntityId ~= localPedId then
        return
    end

    local isTransportEntity = NetworkGetEntityOwner(revivedEntityId) == PlayerId()
    local isRemotePlayer = IsPedAPlayer(revivedEntityId)

    if not isTransportEntity and not isRemotePlayer then
        return
    end

    if isTransportEntity then
        -- local transport = TransportManager.GetTransportFromEntityId(revivedEntityId)

        -- if not transport then
        --     -- #TODO: Matar a entidade novamente caso a gente não ache o transporte
        -- end

        -- Limpar a entidade de sangue/sujeira
        N_0xeb8886e1065654cd(revivedEntityId, 10, "ALL", 10.0)
    end

    -- if isRemotePlayer then
    --     local playerIndex = NetworkGetPlayerIndexFromPed(revivedEntityId)
    --     local playerId = GetPlayerServerId(playerIndex)
    -- end

    TriggerServerEvent("net.game.itemReviverUsed", NetworkGetNetworkIdFromEntity(revivedEntityId))
end

-- Eventos
AddEventHandler("game.networkDamageEntity", function(event)
    HandleNetworkEntityDamage( event )
end)
AddEventHandler("gameEvent:EVENT_REVIVE_ENTITY", function(event)
    ProcessEventRevivedEntity( event )
end)
