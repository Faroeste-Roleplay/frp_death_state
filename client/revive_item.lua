local exp = exports.ox_inventory

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

    if not isSelfRevive then

        local localPlayerId = PlayerId()

        local localPlayerPos = GetEntityCoords(localPlayerPedId)

        local nearbyIncapacitatedPlayers = { }

        for _, playerId in ipairs(GetActivePlayers()) do

            if playerId ~= localPlayerId then

                local playerPedId = GetPlayerPed(playerId)

                if playerPedId ~= 0 then

                    -- IsPedIncapacitated
                    if N_0xb655db7582aec805(playerPedId) ~= 0 then

                        table.insert(nearbyIncapacitatedPlayers,
                        {
                            playerId = playerId,
                            distanceToLocalPlayer = #(GetEntityCoords(playerPedId) - localPlayerPos)
                        })
                    end
                end
            end
        end

        table.sort(nearbyIncapacitatedPlayers, function(a, b)
            return a.distanceToLocalPlayer < b.distanceToLocalPlayer
        end)

        local nearestIncapacitatedPlayer = nearbyIncapacitatedPlayers[1]

        if not nearestIncapacitatedPlayer then
            cAPI.Notify("error", 'Nenhum jogador ferido por perto!', 5000)
            return
        end

        if nearestIncapacitatedPlayer.distanceToLocalPlayer > 1.5 then
            cAPI.Notify("error", 'O jogador ferido mais próximo está longe demais!', 5000)
            return
        end

        if IsPlayerBeingRevived(GetPlayerServerId(nearestIncapacitatedPlayer.playerId)) then
            cAPI.Notify("error", 'O jogador mais próximo já está sendo revivido!', 5000)
            return
        end

        RequestAnimDict(REVIVAL_ANIMATION_DICTIONARY)

        while not HasAnimDictLoaded(REVIVAL_ANIMATION_DICTIONARY) do
            Citizen.Wait(0)
        end

        local taskSequenceId = OpenSequenceTask()
        --[[ 0 ]] TaskTurnPedToFaceEntity(0, GetPlayerPed(nearestIncapacitatedPlayer.playerId), 1000, 2048, 3)
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