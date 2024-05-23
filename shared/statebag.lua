function GetPlayerStateBagValue(playerId, key)
    return Player(playerId).state[key]
end

function SetPlayerStateBagValue(playerId, key, value, replicated)
    Player(playerId).state:set(key, value, replicated)
end