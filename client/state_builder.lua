StateBuilder = { }

function StateBuilder:new()
    return setmetatable({ state = State:new() }, { __index = StateBuilder })
end

function StateBuilder:onEntry(fn)
    self.state.onEntry = fn

    return self
end

function StateBuilder:onExit(fn)
    self.state.onExit = fn

    return self
end

function StateBuilder:onEntryFrom(triggerType, fn)
    self.state.entryFrom[triggerType] = fn

    return self
end

function StateBuilder:permit(triggerType, stateType)
    assert(triggerType)
    assert(stateType)

    self.state.permits[triggerType] = stateType

    return self
end

function StateBuilder:onUpdate(fn)
    self.state.onUpdate = fn

    return self
end

function StateBuilder:build()
    return self.state
end