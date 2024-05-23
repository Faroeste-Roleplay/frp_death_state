local gPostFxPreloadingTick = nil

local gPostFxPlayingName = nil

function postfxPreloadStop()
    if not gPostFxPreloadingTick then
        return
    end

    gPostFxPreloadingTick = nil
end

function postfxPreloadStart(postFxName)
    -- AnimpostfxPreloadPostfx
    N_0x5199405eabfbd7f0(postFxName)

    gPostFxPreloadingTick = true

    CreateThread(function()
        while gPostFxPreloadingTick do

            -- AnimpostfxHasLoaded | _AnimpostfxIsLoading
            if N_0xbf2dd155b2adcd0a(postFxName) ~= 0 then
                AnimpostfxPlay(postFxName)

                postfxPreloadStop()
            end

            Wait(0)
        end
    end)
end

function postfxPlay(postFxName, preload)
    postfxStop()

    gPostFxPlayingName = postFxName

    if preload then
        postfxPreloadStart(postFxName)
    else    
        AnimpostfxPlay(postFxName)
    end
end

function postfxStop()
    if not gPostFxPlayingName then
        return
    end

    postfxPreloadStop()

    -- AnimpostfxClearEffect
    N_0xc5cb91d65852ed7e(gPostFxPlayingName)

    -- AnimpostfxSetToUnload
    N_0x37d7bdba89f13959(gPostFxPlayingName)

    gPostFxPlayingName = nil
end
