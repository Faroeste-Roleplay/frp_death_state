State = { }

function State:new()
    return {
        entryFrom = { },

        onEntry = nil,
        onExit = ni,

        permits = { },

        onUpdate = nil,
    }
end