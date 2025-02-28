function GetPlayerStateBagValue(playerId, key)
    return Player(playerId).state[key]
end

function SetPlayerStateBagValue(playerId, key, value, replicated)
    Player(playerId).state:set(key, value, replicated)
end

function GetEntityStateBagValue(entityId, key)
    return Entity(entityId).state[key]
end

function SetEntityStateBagValue(entityId, key, value, replicated)
    Entity(entityId).state:set(key, value, replicated)
end