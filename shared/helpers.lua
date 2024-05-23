function IsPlayerMidInteraction(playerId)

    if IsPlayerBeingRevived(playerId) then
        return true
    end

    if IsPlayerReviving(playerId) then
        return true
    end

    if IsPlayerBeingAppliedPotentMedicine(playerId) then
        return true
    end

    if IsPlayerApplyingPotentMedicine(playerId) then
        return true
    end

    return false
end