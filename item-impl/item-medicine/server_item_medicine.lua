local POTENT_MEDICINE_APPLY_COOLDOWN = 120 --[[ secs ]]

exports('itemMedicine', function(event, item, inventory, slot, data)
    local playerId = inventory.id

    local User = API.GetUserFromSource(playerId)
    local Character = User:GetCharacter()

    local playerStateType = GetPlayerStateType(Character)

    if event == 'usingItem' then
        if playerStateType ~= eStateType.Alive then
            cAPI.Notify(playerId, "error", 'Você não pode tomar isso sozinho caso esteja machucado', 5000)
            return false
        end

        local playerPedId = GetPlayerPed(playerId)

        local nearestWoundedPlayers = GetPlayersNearPointWithAnyDeathState(GetEntityCoords(playerPedId), eStateType.Wounded)

        table.sort(nearestWoundedPlayers, function(a, b)
            return a.distance < b.distance
        end)

        local nearestWoundedPlayer = nearestWoundedPlayers[1]
        
        if not nearestWoundedPlayer then
            cAPI.Notify(playerId, "error", 'Nenhum jogador machucado por perto!', 5000)
            return false
        end

        if nearestWoundedPlayer.distance > 1.0 then
            cAPI.Notify(playerId, "error", 'O jogador machucado mais próximo está longe demais!', 5000)
            return false
        end

        local victimPlayer = nearestWoundedPlayer.player

        local victimPlayerId = victimPlayer:GetSource()

        if IsPlayerMidInteraction(victimPlayerId) then
            TriggerClientEvent('texas:notify:native', playerId, 'Você não pode usar esse item agora!', 5000)
            return false
        end

        if not CanPlayerBeAppliedPotentMedicine(victimPlayerId) then
            TriggerClientEvent('texas:notify:native', playerId, 'Aguarde um momento antes de tentar medicar este jogador!', 5000)
            return false
        end

        StartApplyPotentMedicineInteraction(Character, victimPlayerId)

        return true
    end

    if event == 'usedItem' then

        local victimPlayerId = GetPlayerBeingAppliedPotentMedicineByPlayer(playerId)

        local victimPlayer = API.GetUserFromSource(victimPlayerId)

        ClearApplyPotentMedicineInteraction(player, victimPlayerId)
        
        local victimCharacter = victimPlayer:GetCharacter()

        local victimPlayerStateType = GetPlayerStateType(victimCharacter)

        if playerStateType ~= eStateType.Alive then
            cAPI.Notify(playerId, "error", 'Você precisa estar vivo!', 5000)
            return false
        end
        if victimPlayerStateType ~= eStateType.Wounded then
            cAPI.Notify(playerId, "error", 'Este jogador não mais machucado!', 5000)
            return false
        end
        if not CanPlayerBeAppliedPotentMedicine(victimCharacter) then
            cAPI.Notify(playerId, "error", 'Aguarde um momento antes de tentar medicar este jogador!', 5000)
            return false
        end

        IncreasePlayerPotentMedicineStats(victimPlayerId)

        TriggerClientEvent('net.changePlayerHealth', victimPlayerId, 50.0)

        -- local inventoryId = glow:GetSessionCharacterInventory()

        -- local item = exports.ox_inventory:GetSlot(playerId, slot)

        -- local totalDurabilityTimeInSeconds = item.metadata.degrade * 60

        -- --[[
        --     Sempre remover 50% da durabilidade total;
        --     Faz com que o item seja usável no máximo 2 vezes.
        -- ]]
        -- local newDurabilityStamp = item?.metadata?.durability - (totalDurabilityTimeInSeconds / 2)

        -- --[[ Remover 50% da durabilidade a cada uso ]]
        -- exports.ox_inventory:SetDurability(playerId, slot, newDurabilityStamp)
        
        -- if newDurabilityStamp > os.time() then
        --     --[[ Não consumir caso ainda tenha durabilidade ]]
        --     return false
        -- end

        --[[ Consumir o item depois de usar 2 vezes ]]
        return true
    end

    if event == 'buying' then
        return true
    end
    
    return false
end)

function CanPlayerBeAppliedPotentMedicine(playerId)
    local timePotentMedicineLastTaken = GetPlayerTimeLastTakenPotentMedicine(playerId)

    if timePotentMedicineLastTaken and GetGameTimer() - timePotentMedicineLastTaken < (POTENT_MEDICINE_APPLY_COOLDOWN * 1000) then
        return false
    end

    return true
end

function StartApplyPotentMedicineInteraction(player, victimPlayerId)
    local playerId = player:GetSource()

    SetPlayerIsBeingAppliedPotentMedicine(victimPlayerId, playerId)

    SetPlayerIsApplyingPotentMedicine(playerId, victimPlayerId)
end

function ClearApplyPotentMedicineInteraction(player, victimPlayerId)
    local playerId = player:GetSource()

    SetPlayerIsBeingAppliedPotentMedicine(victimPlayerId, nil)

    SetPlayerIsApplyingPotentMedicine(playerId, nil)
end

function IncreasePlayerPotentMedicineStats(playerId)
    Player(playerId).state:set('deathfsm:timePotentMedicineLastTaken', GetGameTimer(), false)

    --[[
    local numPotentMedicineTaken = player.getSessionVar('deathfsm:numPotentMedicineTaken') or 0
    numPotentMedicineTaken += 1
    player.setSessionVar('deathfsm:numPotentMedicineTaken', numPotentMedicineTaken)
    return numPotentMedicineTaken
    --]]
end

function ResetPlayerPotentMedicineStats(playerId)
    Player(playerId).state:set('deathfsm:timePotentMedicineLastTaken', nil, false)
end

function GetPlayerTimeLastTakenPotentMedicine(playerId)
    return Player(playerId).state['deathfsm:timePotentMedicineLastTaken']
end