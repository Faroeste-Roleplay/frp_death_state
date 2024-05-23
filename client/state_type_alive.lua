function onAlive()
    local entityId = PlayerPedId()

    if IsEntityDead(entityId) then
        local resurrectPosition = GetEntityCoords(entityId)

        NetworkResurrectLocalPlayer(resurrectPosition.x, resurrectPosition.y, resurrectPosition.z, GetEntityHeading(entityId), false, false, true, false)

        SetEntityHealth(entityId, 101)

        -- Tentar mitigar o efeito de 'teleporte' criado pelo NetworkResurrect.
        SetPedToRagdoll(entityId, 0, 1, 0, false, false, false)
    end

    -- IsPedIncapacitated
    if N_0xb655db7582aec805(entityId) ~= 0 then
        -- IncapacitatedRevive
        N_0xf6262491c7704a63(entityId, 0)
    end
end

function onAliveByCommand()
    onAlive()

    local entityId = PlayerPedId()

    --[[ Recuperar a vida do player. ]]

    SetEntityHealth(entityId, 200)

    -- SetAttributeCoreValue
    Citizen.InvokeNative(0xC6258F41D86676E0, entityId, 0 --[[ ATTRIBUTE_CORE_HEALTH ]], 100)
end