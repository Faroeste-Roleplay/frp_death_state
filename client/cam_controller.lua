useOrbitalCam()
useControllableOrbitalCam()

gOrbitalCamPreviewIsEnabled = false

function startPreviewUsingOrbitalCam(entity)
    if entity then
        SetOrbitalCamLookAtPosition(GetEntityCoords(entity))

        SetOrbitalCamDistanceToLookAtPos(3.0)

        SetOrbitalCamMinDistanceToLookAtPos(2.0)
        SetOrbitalCamMaxDistanceToLookAtPos(5.0)

        local cam = EnableControllableOrbitalCam()

        gOrbitalCamPreviewIsEnabled = true

        CreateThread(function()
            while gOrbitalCamPreviewIsEnabled do
                Wait(0)
                DisableControlAction(0, 24, true)
                SetOrbitalCamLookAtPosition(GetEntityCoords(entity))
            end
        end)

        return cam
    end
end

function stopPreviewUsingOrbitalCam()
    DisableControllableOrbitalCam(true)
    gOrbitalCamPreviewIsEnabled = false
end