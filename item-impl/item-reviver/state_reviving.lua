function IsEntityBeingRevived(entityId)
    return GetEntityStateBagValue(entityId, 'isBeingRevived') ~= nil
end

function IsPlayerReviving(playerServerId)
    return GetPlayerStateBagValue(playerServerId, 'isRevingPlayer') ~= nil
end