local gDeadSince = nil

local gIsRespawnEnabled = false

local gCameraId = nil

local gPromptId = nil

function onDie()
    local entityId = PlayerPedId()

    -- IsPedIncapacitated
    if N_0xb655db7582aec805(entityId) == 0 then
        --[[ Desabilitar a incapacitação por um frame para garantir que o ped morra. ]]
        -- SetPedCanBeIncapacitated
        N_0x5240864e847c691c(entityId, false)

        --[[ Aplicar um dano no player caso não esteja morto ]]
        ApplyDamageToPed(entityId, GetEntityHealth(entityId), 1, -1, 0)
    else
        --[[ Quase zerar o tempo que demorar para o player sangrar, forçar ele morrer quando estiver incapacitado ]]
        -- SetPedIncapacitationTotalBleedOutDuration
        N_0x2890418b39bc8fff(entityId, 1)
    end

    SetTimeout(0, function()
        --[[ Reabilita a flag de poder ficar incapacitado após um frame. ]]
        -- SetPedCanBeIncapacitated
        N_0x5240864e847c691c(entityId, true)
    end)

    SetTimeout(100, function()
        postfxPlay('DeathFailMP01')
    end)

    local promptId = PromptBuilder:new()
                    :setControl(`INPUT_PC_FREE_LOOK`)
                    :setText('Renascer')
                    :setMode('AutoFill', DEAD_ALLOW_RESPAWN_TIME, DEAD_ALLOW_RESPAWN_TIME)
                    :setVisible(true)
                    :build()

    gPromptId = promptId

    local cam = startPreviewUsingOrbitalCam(PlayerPedId())
    gCameraId = cam

    TriggerServerEvent("FRP:onPlayerDeath")
end

function onDeadExit()
    postfxStop() -- 'DeathFailMP01'

    PromptDelete(gPromptId)
    gPromptId = nil

    gDeadSince = nil

    gIsRespawnEnabled = false

    -- RenderScriptCams(false, true, 3000, true, false, 0)
    -- DestroyCam(gCameraId, false)
    stopPreviewUsingOrbitalCam()
    gCameraId = nil
end

function onDeadUpdate()
    if not gDeadSince then
        gDeadSince = GetGameTimer()
    end

    -- -- SetControlContext
    -- N_0x2804658eb7d8a50b(4, `ONLINEDEATHCAMERA`)

    if gIsRespawnEnabled then
        if PromptHasHoldModeCompleted(gPromptId) then
            respawn()
        end
    end

    if not gIsRespawnEnabled and gPromptId then
        local millisecondsSinceDeath = GetGameTimer() - gDeadSince

        if millisecondsSinceDeath >= DEAD_ALLOW_RESPAWN_TIME then
            gIsRespawnEnabled = true

            PromptSetHoldMode(gPromptId, 1000)
        end
    end
end