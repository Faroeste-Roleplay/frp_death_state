function GetPlayerBeingAppliedPotentMedicineByPlayer(playerServerId)
    return GetPlayerStateBagValue(playerServerId, 'isApplyPotentMedicine')
end

function IsPlayerBeingAppliedPotentMedicine(playerServerId)
    return GetPlayerBeingAppliedPotentMedicineByPlayer(playerServerId) ~= nil
end

function IsPlayerApplyingPotentMedicine(playerServerId)
    return GetPlayerStateBagValue(playerServerId, 'isApplyPotentMedicine') ~= nil
end