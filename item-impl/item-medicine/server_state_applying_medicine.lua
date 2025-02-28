function SetPlayerIsBeingAppliedPotentMedicine(playerId, applyingPlayerId)
    SetPlayerStateBagValue(playerId, 'isBeingAppliedPotentMedicine', applyingPlayerId or nil, true)
end

function SetPlayerIsApplyingPotentMedicine(playerId, victimPlayerId)
    SetPlayerStateBagValue(playerId, 'isApplyPotentMedicine', victimPlayerId or nil, true)
end

function SetPlayerIsBeingRevived(playerId, reviverPlayerId)
    SetPlayerStateBagValue(playerId, 'isBeingRevived', reviverPlayerId or nil, true)
end

function SetPlayerIsRevivingPlayer(playerId, revivingPlayerId)
    SetPlayerStateBagValue(playerId, 'isRevingPlayer', revivingPlayerId or nil, true)
end