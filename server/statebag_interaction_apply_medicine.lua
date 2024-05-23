function SetPlayerIsBeingAppliedPotentMedicine(playerId, applyingPlayerId)
    SetPlayerStateBagValue(playerId, 'isBeingAppliedPotentMedicine', applyingPlayerId or nil, true)
end

function SetPlayerIsApplyingPotentMedicine(playerId, victimPlayerId)
    SetPlayerStateBagValue(playerId, 'isApplyPotentMedicine', victimPlayerId or nil, true)
end