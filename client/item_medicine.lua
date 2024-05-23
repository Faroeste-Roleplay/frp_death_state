local ANIMATION_DICT = 'mech_skin@sample@base'
local ANIMATION_NAME = 'sample_high'

exports('itemMedicine', function(data, slot)

    if IsPlayerMidInteraction(-1) then
        cAPI.Notify("error", 'Você não pode usar esse item agora!', 5000)
        return
    end

    RequestAnimDict(ANIMATION_DICT)

    while not HasAnimDictLoaded(ANIMATION_DICT) do
        Citizen.Wait(0)
    end

    data.client.usetime = GetAnimDuration(ANIMATION_DICT, ANIMATION_NAME) * 1000

    local playerPedId = PlayerPedId()

    --[[
        É necessário porque esse estado é aplicado antes do callback do `useItem` retornar
        então ai é possivel a gente aplicar a animação antes de usar o item completamente
    ]]
    local cookie = AddStateBagChangeHandler('isApplyPotentMedicine', ('player:%d'):format(GetPlayerServerId(PlayerId())), function(bagName, key, value, reserved, replicated)
        local isApplyPotentMedicine = value ~= nil
        
        if not isApplyPotentMedicine then
            return
        end

        local playerServerIdBeingAppliedPotentMedicine = isApplyPotentMedicine and value

        local taskSequenceId = OpenSequenceTask()
        --[[ 0 ]] TaskTurnPedToFaceEntity(0, GetPlayerPed(GetPlayerFromServerId(playerServerIdBeingAppliedPotentMedicine)), 1000, 2048, 3)
        --[[ 1 ]] TaskPlayAnim(0, ANIMATION_DICT, ANIMATION_NAME, 8.0, -8.0, -1, 0, 0, true, 0, false, 0, false)
        CloseSequenceTask(taskSequenceId)
        TaskPerformSequence(playerPedId, taskSequenceId)
        ClearSequenceTask(taskSequenceId)
    end)

    exports.nxt_inventory:useItem(data, function(result)

        RemoveAnimDict(ANIMATION_DICT)

        RemoveStateBagChangeHandler(cookie)

        if not result then
            return
        end

        ClearPedTasks(playerPedId, false, false)
    end)
end)

local gIsBeingAppliedPotentMedicine

AddStateBagChangeHandler('isBeingAppliedPotentMedicine', ('player:%d'):format(GetPlayerServerId(PlayerId())), function(bagName, key, value, reserved, replicated)
    gIsBeingAppliedPotentMedicine = value ~= nil

    if gIsBeingAppliedPotentMedicine then
        CreateThread(function()
            while gIsBeingAppliedPotentMedicine do
                Wait(0)

                --[[ Desabilita o movemento do player ]]
                DisableControlAction(0, `INPUT_MOVE_LR`, true)
                DisableControlAction(0, `INPUT_MOVE_UD`, true)
                DisableControlAction(0, `INPUT_DUCK`, true)
                DisableControlAction(0, `INPUT_SPRINT`, true)
            end
        end)
    end
end)