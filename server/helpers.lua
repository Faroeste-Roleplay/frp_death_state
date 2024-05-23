function GetPlayersNearPointWithAnyDeathState(point, searchDeathState)
    local p = promise.new()
    
    local players = API.GetUsers()
    local playersNearPoint = { }

    for userId, User in pairs(players) do
        local playerId = User:GetSource()
        local Character = User:GetCharacter()

        local playerPedId = GetPlayerPed(playerId)

        if playerPedId ~= 0 then

            if GetPlayerStateType(Character) == searchDeathState then
                table.insert(playersNearPoint,
                {
                    player   = Character,
                    distance = #(GetEntityCoords(playerPedId) - point)
                })
            end
        end
    end

    p:resolve(playersNearPoint)

    return Citizen.Await(p)
end
