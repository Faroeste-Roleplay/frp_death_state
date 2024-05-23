function SetPlayerIsBeingRevived(playerId, reviverPlayerId)
    SetPlayerStateBagValue(playerId, 'isBeingRevived', reviverPlayerId or nil, true)
end

function SetPlayerIsRevivingPlayer(playerId, revivingPlayerId)
    SetPlayerStateBagValue(playerId, 'isRevingPlayer', revivingPlayerId or nil, true)
end