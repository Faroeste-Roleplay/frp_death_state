StateMachine = { }

function StateMachine:new(initialStateType)
    local self = setmetatable({
        states = { },

        initialStateType = initialStateType,

        currentStateType = nil,

        stateChangeHandler = nil,
    },
    { __index = StateMachine })

    return self
end

function StateMachine:start()
    assert(self.initialStateType)

    self:entryStateFrom(self.initialStateType, nil)

    self.initialStateType = nil

    CreateThread(function()
        while true do
            Wait(0)

            self:update()
        end
    end)
end

function StateMachine:configure(stateType)
    local builder = StateBuilder:new()

    self.states[stateType] = builder:build()

    return builder
end

function StateMachine:exitState()
    if not self.currentStateType then
        return
    end

    local state = self.states[self.currentStateType]

    -- state.onExit?()
    if state.onExit then
        state.onExit()
    end
end

function StateMachine:entryStateFrom(stateType, triggerType)
    self:exitState()

    local oldStateType = self.currentStateType

    self.currentStateType = stateType

    if self.stateChangeHandler then
        Citizen.CreateThreadNow(function()
            self.stateChangeHandler(oldStateType, stateType)
        end)
    end

    local state = self.states[stateType]

    local entry = triggerType and state.entryFrom[triggerType] or state.onEntry

    -- entry?()
    if entry then
        entry()
    end
end

function StateMachine:fire(triggerType)
    local state = self.states[self.currentStateType]

    local nextState = state.permits[triggerType]

    if not nextState then
        return
    end

    self:entryStateFrom(nextState, triggerType)
end

function StateMachine:setStateChangeHandler(fn)
    self.stateChangeHandler = fn
end

function StateMachine:getCurrentStateType()
    return self.currentStateType
end

function StateMachine:update()
    local state = self.states[self.currentStateType]

    if state?.onUpdate then
        state.onUpdate()
    end
end