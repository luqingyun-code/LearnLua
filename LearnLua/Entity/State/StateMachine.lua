local Class = require("Class")

local StateMachine = Class()

function StateMachine:_Init(owner)
    self.owner = owner
    self.states = {} --name->state
    self.current = nil
    self.currentName = nil
end

function StateMachine:addState(name, stateClass)
     local state = stateClass.New(self,self.owner)
     state.name = name
     self.states[name] = state
end

function StateMachine:switchTo(name, nextState, ...)
    if self.current then
        self.current:onExit(name)
    end
    self.current = nextState
    self.currentName = name
    self.current:onEnter(...)
end

function StateMachine:changeState(name)
    local nextState = self.states[name]
    if not nextState then
        error("[StateMachine] 无法转为不存在的状态："..tostring(name))
    end
    if name == self.currentName and not self.current.allowReenter then return end
    if self.current and nextState.priority < self.current.priority then return end
    self:switchTo(name, nextState)
end

function StateMachine:forceState(name)
    local nextState = self.states[name]
    if not nextState then
        error("[StateMachine] 无法转为不存在的状态："..tostring(name))
    end
    if name == self.currentName then return end
    self:switchTo(name, nextState)
end

function StateMachine:update(dt)
    self.current:onUpdate(dt)
end


return StateMachine