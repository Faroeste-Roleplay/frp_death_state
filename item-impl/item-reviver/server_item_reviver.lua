exports('reviverItem', function(event, item, inventory, slot, data)
    
    if event == 'buying' then
        return true
    end

    local reviverPlayerId = inventory.id

    local User   = API.GetUserFromSource(reviverPlayerId)
    local reviverCharacter = User:GetCharacter()

    local victimKind = item.name == 'reviver' and 'player' or 'horse'

    if event == 'usingItem' then

        local reviverPlayerStateType = GetPlayerStateType(reviverCharacter)

        local isSelfRevive = reviverPlayerStateType == eStateType.Incapacitated

        local reviverPlayerEntityId = GetPlayerPed(reviverPlayerId)

        local revivedPlayerId = isSelfRevive and reviverPlayerId or nil
        local victimEntityId = isSelfRevive and reviverPlayerEntityId or nil

        if not isSelfRevive then
            local reviverPlayerPos = GetEntityCoords(reviverPlayerEntityId)
    
            local candidates
        
            if victimKind == 'player' then
                candidates = GetPlayersNearPoint(reviverPlayerPos, 1.5)
            end
    
            if victimKind == 'horse' then
                candidates = TransportManager.GetHorsesNearPoint(reviverPlayerPos, 1.5)
            end

            --[[ Achar o primeiro candidato que está incapacitado, eles já estão ordenados pela distancia ]]
            local candidate = table.find(candidates, function(candidate)
                local candidateId, candidateEntityId, candidateDistance = table.unpack(candidate)

                if victimKind == 'player' then
                    local User = API.GetUserFromCitizenId(candidateId)
                    
                    if User then
                        local Character = User:GetCharacter()

                        local playerStateType = GetPlayerStateType(Character)

                        if playerStateType == eStateType.Incapacitated then
                            return true
                        end
                    end
                end

                if victimKind == 'horse' then

                    print(" HORSE :: ", TransportManager.GetTransportDeathState(candidateId) )
                    if TransportManager.GetTransportDeathState(candidateId) == eStateType.Incapacitated then
                        return true
                    end
                end

                return false
            end)
    
            print(" candidate :: 2 ", json.encode(candidate, {indent=true}))

            if not candidate then
                -- error('Ninguem por perto!')
                return false
            end

            local candidateId, candidateEntityId, candidateDistance = table.unpack(candidate)

            print(" candidateId :; ", candidateId, candidateEntityId)

            if IsPlayerMidInteraction(candidateId) or IsEntityBeingRevived(candidateEntityId) then
                -- error('Esse jogador já está sendo revivido!')
                return false
            end

            victimEntityId = candidateEntityId
        end

        if not victimEntityId then
            -- error('ninguem para ser revivido')
            return false
        end

        if victimKind == "player" then
            SetEntityIsBeingRevivedByThisPlayer(victimEntityId, true)

            SetPlayerIsRevivingThisEntity(reviverPlayerId, victimEntityId)

            reviverCharacter:SetSessionVar('playerIdBeingRevivedByMe', revivedPlayerId)
        end


        print(" FIM ::: ")

        return true
    end

    if event == 'usedItem' then

        -- print(" usedItem ::  ", reviverPlayerId, victimEntityId)

        local victimEntityId = GetEntityBeingRevivedByThisPlayer(reviverPlayerId)

        -- print(" victimEntityId :: ", victimEntityId)

        if not victimEntityId then
            
            -- if victimKind == "horse" then
            --     Server.SetEntityGamestate(victimEntityId, 'Alive')
            -- end

            return false
        end

        SetEntityIsBeingRevivedByThisPlayer(victimEntityId, false)

        SetPlayerIsRevivingThisEntity(reviverPlayerId, nil)

        --[[ TODO: Parar de usar essa função, é estranha pra caralho. ]]
        Server.SetEntityGamestate(victimEntityId, 'Alive')
        -- TriggerClientEvent('net.deathfsm.fire', playerIdBeingRevived, eTriggerType.Revive)

        return true
    end

    return false
end)


function GetEntityBeingRevivedByThisPlayer(playerId)
    return Player(playerId).state['entityIdBeingRevivedByMe']
end

function SetPlayerIsRevivingThisEntity(playerId, entityId)
    Player(playerId).state:set('entityIdBeingRevivedByMe', entityId, false)
end