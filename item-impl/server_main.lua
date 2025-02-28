CreateThread(function ()

    for _, playerId in ipairs(GetPlayers()) do
        SetEntityIsBeingRevivedByThisPlayer(GetPlayerPed(playerId), nil)
        SetPlayerIsRevivingPlayer(playerId, nil)
    
        SetPlayerIsBeingAppliedPotentMedicine(playerId, nil)
        SetPlayerIsApplyingPotentMedicine(playerId, nil)
    
        ResetPlayerPotentMedicineStats(playerId)
    end
end)

-- TODO: Usar o scopo do onesync para calcular somente a distancia dos players que estão no mesmo scopo
function GetPlayersNearPoint(point, searchDeathState)
    local ret = { }

    for _, playerId in pairs(GetPlayers()) do

        local playerPedId = GetPlayerPed(playerId)

        if playerPedId ~= 0 then

            local distanceToPoint = #(GetEntityCoords(playerPedId) - point)

            table.insert(ret,
            {
                playerId,
                playerPedId,
                distanceToPoint,
            })
        end
    end

    return ret
end