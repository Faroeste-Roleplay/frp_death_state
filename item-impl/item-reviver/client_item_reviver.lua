local exp = exports.ox_inventory

local REVIVAL_ANIMATION_DICTIONARY = 'mech_revive@unapproved'
local REVIVAL_ANIMATION_NAME = 'revive'

local SELF_REVIVAL_TIME = 20000 --[[ milliseconds ]]

exports('reviverItem', function(data, slot)
    local localPlayerPedId = PlayerPedId()

    local currentDeathStateType = GetCurrentStateType()

    local isDead = currentDeathStateType == eStateType.Dead 

    local isAllowedToUseReviver = not isDead

    if not isAllowedToUseReviver then
        cAPI.Notify("error", 'Você não pode usar esse item agora!', 5000)
        return
    end
    
    local isIncapacitated = currentDeathStateType == eStateType.Incapacitated

    local isSelfRevive = isAllowedToUseReviver and isIncapacitated

    local victimKind = data.name == 'reviver' and 'player' or 'horse'

    if not isSelfRevive then

        local localPlayerPos = GetEntityCoords(localPlayerPedId)

        local candidates
        
        if victimKind == 'player' then
            candidates = GetPlayersNearPoint(localPlayerPos, 1.5)
        end

        if victimKind == 'horse' then
            candidates = TransportManager.GetHorsesNearPoint(localPlayerPos, 1.5)
        end

        --[[ Achar o primeiro candidato que está incapacitado, eles já estão ordenados pela distancia ]]
        local candidate = table.find(candidates, function(candidate)
            local candidateId, candidateEntityId, candidateDistance = table.unpack(candidate)

            -- IsPedIncapacitated
            if N_0xb655db7582aec805(candidateEntityId) ~= 0 then
                return true
            end

            return false
        end)


        if not candidate then
            return cAPI.Notify("error", 'Nenhum jogador ou cavalo ferido por perto!', 5000)
        end

        local candidateId, candidateEntityId, candidateDistance = table.unpack(candidate)

        if IsEntityBeingRevived(candidateId) then
            return cAPI.Notify("error", 'O jogador ou cavalo mais próximo já está sendo revivido!', 5000)
        end

        RequestAnimDict(REVIVAL_ANIMATION_DICTIONARY)

        while not HasAnimDictLoaded(REVIVAL_ANIMATION_DICTIONARY) do
            Citizen.Wait(0)
        end

        local taskSequenceId = OpenSequenceTask()
        --[[ 0 ]] TaskTurnPedToFaceEntity(0, candidateEntityId, 1000, 2048, 3)
        --[[ 1 ]] TaskPlayAnim(0, REVIVAL_ANIMATION_DICTIONARY, REVIVAL_ANIMATION_NAME, 8.0, -8.0, -1, 0, 0, true, 0, false, 0, false)
        CloseSequenceTask(taskSequenceId)
        TaskPerformSequence(localPlayerPedId, taskSequenceId)
        ClearSequenceTask(taskSequenceId)

        RemoveAnimDict(REVIVAL_ANIMATION_DICTIONARY)

        --[=[
        while GetSequenceProgress(localPlayerPedId) ~= 1 --[[ TaskPlayAnim ]] do
            Wait(0)
        end
        --]=]
    end

    local useDuration = isSelfRevive and SELF_REVIVAL_TIME or GetAnimDuration(REVIVAL_ANIMATION_DICTIONARY, REVIVAL_ANIMATION_NAME) * 1000

    data.client.usetime = useDuration

    exp:useItem(data, function(result)

        ClearPedTasks(localPlayerPedId, false, false)

        if not result then
            return
        end
    end)
end)

function GetPlayersNearPoint(point, maxDistance)
    local INDEX_DISTANCE = 3

    local playerAndDistancePair = { }

    for _, playerId in ipairs(GetActivePlayers()) do

        local playerPedId = GetPlayerPed(playerId)

        if playerPedId ~= 0 then

            local distanceToPoint = #(point - point)

            table.insert(playerAndDistancePair,
            {
                GetPlayerServerId(playerId),
                GetPlayerPed(playerId),
                distanceToPoint
            })
        end
    end

    --[[ Organizar baseado na distancia ]]
    table.sort(playerAndDistancePair, function(pairA, pairB)
        local distanceToPointA = pairA[INDEX_DISTANCE]
        local distanceToPointB = pairB[INDEX_DISTANCE]

        return distanceToPointA < distanceToPointB
    end)

    if maxDistance then
        playerAndDistancePair = table.filter(playerAndDistancePair, function(pair)
            local distanceToPoint = pair[INDEX_DISTANCE]

            return distanceToPoint <= maxDistance
        end)
    end

    return playerAndDistancePair
end