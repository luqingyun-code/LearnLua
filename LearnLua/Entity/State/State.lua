local Class = require("Class")


local State = Class()

State.priority = 0
State.allowReenter = false

function State:_Init(machine,owner)
    self.machine = machine
    self.owner = owner
end

function State:onEnter() end

function State:onUpdate(dt) end

function State:onExit(nextStateName) end


return State