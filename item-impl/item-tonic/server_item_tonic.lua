exports('itemTonic', function(event, item, inventory, slot, data)

    if event == 'usingItem' then
        local playerId = inventory.id
        local User   = API.GetUserFromSource(playerId)
        local Character = User:GetCharacter()

        local playerStateType = GetPlayerStateType(Character)

        local stateLocalized = nil

        if playerStateType == eStateType.Incapacitated then
            stateLocalized = 'incapacitado'
        elseif playerStateType == eStateType.Wounded then
            stateLocalized = 'machucado'
        elseif playerStateType == eStateType.Dead then
            stateLocalized = 'morto'
        end
        
        if stateLocalized then
            cAPI.Notify(playerId, "error", ('Você não pode usar items de cura enquanto estiver %s!'):format(stateLocalized), 5000)
            return false
        end

        return true
    end

    return true
end)