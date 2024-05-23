function onIncapacitate()
    local entityId = PlayerPedId()

    --[[ Garantir que o tempo de bleedout está no padrão, já que o state 'Dead' altera ele ]]
    -- SetPedIncapacitationTotalBleedOutDuration
    N_0x2890418b39bc8fff(entityId, INCAPACITATED_BLEEDOUT_DURATION)

    -- IsPedIncapacitated
    if N_0xb655db7582aec805(entityId) == 0 then
        SetEntityHealth(entityId, 0)
    end

    postfxPlay('MP_Downed')
end

function onIncapacitatedExit()
    postfxStop() -- 'MP_Downed'
end