local gIsStateReady = false

function onWounded()
    onAlive()

    local entityId = PlayerPedId()

    N_0xcb9401f918cb0f75(entityId, 'BLOCK_CAMERA_DRUNK_SLUMP_BEHAVIOUR', true, -1)

    -- Setar o tipo de locomotion
    N_0x89f5e7adecccb49c(entityId, 'very_drunk')

    -- Intensidade da estado de bebado / Locomotion.
    N_0x406ccf555b04fad3(entityId, true, 1.0)

    -- SetPedBlackboardBool
    N_0xcb9401f918cb0f75(entityId, 'IsDrunk', true, -1)

    -- SetPedBlackboardFloat
    N_0x437c08db4febe2bd(entityId, 'Drunkness', 1.0, -1)

    SetPedMaxMoveBlendRatio(entityId, 0.1)

    postfxPlay('MP_BountyLagrasSwamp')

    CreateThread(function()

        --[[ Gambiarra... parece que `IncapacitatedRevive` não seta a vida em 101 sempre no proximo frame, mas em um frame aleatorio ]]
        while GetEntityHealth(entityId) ~= 10 do
            SetEntityHealth(entityId, 10, 0)

            Wait(0)
        end

        --[[ WARNING: Pode acontecer do estado mudar antes da gente terminar esse loop!! ]]

        gIsStateReady = true
    end)
end

function onWoundedExit()
    gIsStateReady = false

    local entityId = PlayerPedId()

    -- SetPedBlackboardBool
    N_0xcb9401f918cb0f75(entityId, 'BLOCK_CAMERA_DRUNK_SLUMP_BEHAVIOUR', false, -1)

    -- Remover o locomotion type atual 'very_drunk'
    N_0x58f7db5bd8fa2288(entityId)

    -- Intensidade da estado de bebado.
    N_0x406ccf555b04fad3(entityId, false, 0.0)

    -- SetPedBlackboardBool
    N_0xcb9401f918cb0f75(entityId, 'IsDrunk', false, -1)

    -- SetPedBlackboardFloat
    N_0x437c08db4febe2bd(entityId, 'Drunkness', 0.0, -1)

    SetPedMaxMoveBlendRatio(entityId, 1.0)

    postfxStop()

    SetPlayerHealthRechargeMultiplier(PlayerId(), 1.0)
end

function onWoundedUpdate()
    local entityId = PlayerPedId()

    SetPlayerHealthRechargeMultiplier(PlayerId(), 0.1) -- ~10 Minutos para chegar em 110 de vida.

    if gIsStateReady and GetEntityHealth(entityId) >= 101 then
        heal()
    end
end