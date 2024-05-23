function IsPlayerBeingRevived(playerServerId)
    return GetPlayerStateBagValue(playerServerId, 'isBeingRevived') ~= nil
end

function IsPlayerReviving(playerServerId)
    return GetPlayerStateBagValue(playerServerId, 'isRevingPlayer') ~= nil
end