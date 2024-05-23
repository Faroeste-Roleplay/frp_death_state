local SPAWNPOINTS =
{
    vector3(69.97, -616.47, 43.20),
    vector3(61.77, -617.17, 43.03),
    vector3(49.56, -612.95, 46.30),
    vector3(1470.45, -1989.92, 41.61),
    vector3(1487.22, -1993.05, 44.30), -- Em baixo de Bolber Blade (BraithWaite Manor)
    vector3(1486.95, -1980.446, 44.30),
    vector3(845.329, -978.06, 41.65),
    vector3(831.83, -947.87, 41.58),
    -- vector3(120.354, -802.64, 41.156),
    vector3(2115.564, -782.97, 41.867),
    vector3(-227.91, 1172.66, 93.11),
    vector3(-243.56, 1159.735, 92.549),
    vector3(-255.52, 1174.32, 92.23),
    vector3(-5443.272, -4036.887, -31.608),
    vector3(-5441.301, -4024.03, -29.30),
    vector3(-1765.83, -1160.357, 73.38),
}

function onRespawn()
    NetworkSetEntityInvisibleToNetwork(PlayerPedId(), true)

    postfxPlay('RespawnWithHonor')

    DoScreenFadeOut(2000)

    while not IsScreenFadedOut() do
        Wait(0)
    end

    local rnd = math.floor(math.random() * #SPAWNPOINTS)

    local spawnpoint = SPAWNPOINTS[rnd]
    local heading = math.floor(math.random() * 360.0) + 1

    StartPlayerTeleport(PlayerId(), spawnpoint.x, spawnpoint.y, spawnpoint.z, heading, true, true, true)
    
    while IsPlayerTeleportActive() do
        Wait(0)
    end

    alive()
end

function onRespawnExit()
    NetworkSetEntityInvisibleToNetwork(PlayerPedId(), false)

    postfxStop()

    DoScreenFadeIn(1000)
end