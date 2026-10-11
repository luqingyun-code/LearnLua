local Class = require("Class")
local State = require("State")
local EntityState = require("EntityState")

local TimedState = EntityState.TimedState
local MoveState = EntityState.MoveState
local EntityStateMachine = EntityState.EntityStateMachine

local PlayerIdleState = Class(State)

local PlayerMoveState = Class(MoveState)

function PlayerMoveState:_Init()
    
end

function MoveState:onEnter()
    local owner = self.owner
    local pos = owner.go.transform.position
    self.startX = pos.x
    self.startY = pos.y
    self.startZ = pos.z
    owner.animator:SetBool("isMoving", true)
end

function PlayerMoveState:onMoving()
    
end

function PlayerMoveState:getDirection()
    
end

function PlayerMoveState:onExit()
    self.owner.animator:SetBool("isMoving", false)
end

local WinState = Class(TimedState)