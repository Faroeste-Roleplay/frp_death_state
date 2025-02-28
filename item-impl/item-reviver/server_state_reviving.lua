function SetEntityIsBeingRevivedByThisPlayer(entityId, playerId)
    SetEntityStateBagValue(entityId, 'isBeingRevived', playerId or nil, true)
end

function SetPlayerIsRevivingPlayer(playerId, revivingPlayerId)
    SetPlayerStateBagValue(playerId, 'isRevingPlayer', revivingPlayerId or nil, true)
end