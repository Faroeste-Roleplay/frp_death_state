local Tunnel = module("frp_lib", "lib/Tunnel")
local Proxy = module("frp_lib", "lib/Proxy")

cAPI = Proxy.getInterface("API")

gMachine = nil

local gDeathStateChangeMetadata = nil

function CreateStateMachine()
    local machine = StateMachine:new(eStateType.Alive)

    machine:configure(eStateType.Alive)
        :onEntryFrom(eTriggerType.Revive         , onAlive)
        :onEntryFrom(eTriggerType.ReviveByCommand, onAliveByCommand)
        :onEntryFrom(eTriggerType.Heal           , onAlive)
        :permit(eTriggerType.Incapacitate, eStateType.Incapacitated)
        :permit(eTriggerType.Die         , eStateType.Dead)
        :permit(eTriggerType.Wound       , eStateType.Wounded)
    
    machine:configure(eStateType.Wounded)
        :onEntry(onWounded)
        :onExit(onWoundedExit)
        :permit(eTriggerType.ReviveByCommand, eStateType.Alive)
        :permit(eTriggerType.Incapacitate   , eStateType.Incapacitated)
        :permit(eTriggerType.Die            , eStateType.Dead)
        :permit(eTriggerType.Heal           , eStateType.Alive)
        :onUpdate(onWoundedUpdate)

    machine:configure(eStateType.Incapacitated)
        :onEntryFrom(eTriggerType.Incapacitate, onIncapacitate) -- Quando a transição para o estado 'Incapacitated' for pelo metodo 'Incapacitate'
        :onExit(onIncapacitatedExit) -- Quando sair do estado 'Incapacitated'
        :permit(eTriggerType.Revive         , eStateType.Wounded)
        :permit(eTriggerType.ReviveByCommand, eStateType.Alive) -- Permir a transição do estado 'Incapacitated' para o estado 'Alive' quando o metodo 'Revive' for executado
        :permit(eTriggerType.Die            , eStateType.Dead)

    machine:configure(eStateType.Dead)
        :onEntryFrom(eTriggerType.Die, onDie)
        :onExit(onDeadExit)
        :permit(eTriggerType.Revive         , eStateType.Wounded)
        :permit(eTriggerType.ReviveByCommand, eStateType.Alive)
        :permit(eTriggerType.Respawn        , eStateType.Respawning)
        :onUpdate(onDeadUpdate) -- A cada frame enquanto estiver no estado 'Dead', executar ...

    machine:configure(eStateType.Respawning)
        :onEntryFrom(eTriggerType.Respawn, onRespawn)
        :onExit(onRespawnExit)
        :permit(eTriggerType.ReviveByCommand, eStateType.Alive)

    machine:start()

    return machine
end

function revive()
    gMachine:fire(eTriggerType.Revive)
end

function alive()
    gMachine:fire(eTriggerType.ReviveByCommand)
end

function wound()
    gMachine:fire(eTriggerType.Wound)
end

function incapacitate()
    gMachine:fire(eTriggerType.Incapacitate)
end

function die()
    gMachine:fire(eTriggerType.Die)
end

function respawn()
    gMachine:fire(eTriggerType.Respawn)
end

function heal()
    gMachine:fire(eTriggerType.Heal)
end

function UpdatePlayerIncapacitationFlags()
    local playerPedId = PlayerPedId()

    local flags =
        1           -- INCAPACITATION_FLAG_DISABLE_DEATH_DUE_TO_NO_NEARBY_REVIVERS

                    -- Ficar incapacitado por danos simples, de acordo com os scripts decompilados.
        | 2
        | 16
        | 256
        
                    -- Ficar incapacitado por danos excessivos, de acordo com os scripts decompilados.
        | 4
        | 8
        | 32
        | 64
        | 128

        | 512     -- INCAPACITATION_FLAG_DISABLE_EXECUTION 
        | 1024    -- Setting ped cannot be revived by anyone
        -- | 2048    -- INCAPACITATION_FLAG_DISABLE_REVIVE_FOR_NON_FRIENDLIES
        -- | 4096    -- _INCAPACITATION_FLAG_DISABLE_GIVEUP
        -- | 8192    -- ?
        -- | 16384   -- Only allowing one revive per life.
        -- | 32768   -- ?
        -- | 65536   -- ?
        -- | 131072  -- ?
        -- | 262144  -- ?
        -- | 524288  -- ?
        -- | 1048576 -- ?
        ;

    -- _CLEAR_PED_INCAPACITATION_FLAGS
    N_0x92a1b55a59720395(playerPedId)

    -- SetPedIncapacitationFlags
    N_0xd67b6f3bcf81ba47(playerPedId, flags)

    -- SetPedIncapacitationModifiers
    N_0x39ed303390ddeac7(playerPedId, true, -1.0, INCAPACITATED_BLEEDOUT_DURATION --[[ bleedOutDuration ]], flags)

    SetPedConfigFlag(playerPedId, 176, true) -- FEATURE_REVIVE_TEAMMATES -- não funciona?
end

function GetCurrentStateType()
    return gMachine:getCurrentStateType()
end

CreateThread(function()

    UpdatePlayerIncapacitationFlags()

    --[[ Executado quando o player seleciona um personagem ]]
    -- RegisterNetEvent('net.setCharacterData', function()
        -- UpdatePlayerIncapacitationFlags()
    -- end)

    CreateThread(function()

        local lastPlayerPedId = PlayerPedId()

        while true do
            Wait(100)

            local playerPedId = PlayerPedId()

            if playerPedId ~= lastPlayerPedId then
                UpdatePlayerIncapacitationFlags()

                lastPlayerPedId = playerPedId
            end
        end
    end)

    gMachine = CreateStateMachine()

    gMachine:setStateChangeHandler(function(oldStateType, newStateType)

        local metadata = ClearDeathStateChangeMetadata()

        print( ('StateMachine changed state to %s'):format(eStateType[newStateType]) )

        --[[ NÃO REMOVER!!! É uma 'gambiarra' para impedir que o código abaixo desse Wait seja executado caso esse resource tenha sido stoppado ]]
        Wait(0)

        TriggerServerEvent('net.deathfsm.stateChanged', newStateType, metadata)
    end)

    --[[ Resetar para o estado de 'Alive' quando o resource for stoppado ]]
    AddEventHandler('onResourceStop', function(resourceName)
        if resourceName == GetCurrentResourceName() then
            alive()
        end
    end)

    --[[ Aceitar uma mudança de estado requesitada pelo server ]]
    RegisterNetEvent('net.deathfsm.fire', function(triggerType)

        --[[ A limpa qualquer metadata caso a mudança de estado tenha partido do servidor ]]
        ClearDeathStateChangeMetadata()

        if triggerType == eTriggerType.ReviveByCommand then
            gLastIncapacitationFromDamageAt = nil
            
            --[[ Resetar o número de vezes em que pode ficar incapacitado ]]
        end

        gMachine:fire(triggerType)
    end)
    
    -- #TODO: APLICAR INCAPACITATION FLAGS SEMPRE QUE O PED DO PLAYER MUDAR

    --[=[
    RegisterCommand('trigger', function(source, args, raw)
        gMachine:fire(eTriggerType[args[1]])
    end, false)
    --]=]
end)

function setDeathStateChangeMetadata(data)
    gDeathStateChangeMetadata = data
end

function ClearDeathStateChangeMetadata()
    local data = gDeathStateChangeMetadata

    gDeathStateChangeMetadata = nil

    return data
end