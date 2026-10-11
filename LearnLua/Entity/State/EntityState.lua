local Class = require("Class")
local State = require("State")
local EventManger = require("EventManger")



-->>>>>>>>>>>>>>>>两个中间基类<<<<<<<<<<<<<<
--1.限时状态
local TimedState = Class(State)

function TimedState:onEnter()
    self.timer = 0
    self.elapsed = false
end

function TimedState:onUpdate(dt)
    if self.elapsed then return end
    self.timer = self.timer + dt
    self:onTick(dt)
    if self.timer >= self:getDuration() then
        self.elapsed = true
        self:onElapsed()
    end
end

function TimedState:getDuration() return 0 end

function TimedState:onTick(dt) end

function TimedState:onElapsed() end

--2.移动状态
local MoveState = Class(State)

function MoveState:onUpdate(dt)
    local owner = self.owner
    if owner.hasTarget then
        self.machine:changeState("Idle")
    else
        local dir = self:getDirection()
        local speed = self.owner.moveSpeed
        owner.go.transform:Translate(dir*speed*dt,0,0)
        self:onMoving(dt)
    end
end

function MoveState:getDirection() return 1 end

function MoveState:onMoving(dt) end

-->>>>>>>>>>>>>>>>状态派生类<<<<<<<<<<<<<<
--1.AttackState
local AttackState = Class(TimedState)

function AttackState:onEnter()
    TimedState.onEnter(self)
    local owner = self.owner
    self.animParam = owner:getAnimParam()
    owner.animator:SetBool(self.animParam,true)
    owner.animator.speed = owner:getAttackSpeed()
    self.hasAttacked = false
end

function AttackState:getDuration()
    return self.owner.getAttackDuration()
end

function AttackState:onTick(dt)
    if self.hasAttacked then return end
    if self.timer >= self.owner:getAttackFrame() then
        self.hasAttacked = true
        if self.owner.getCompactType() == "ranged" then
            EventManger:emit("entity.rangedAttackPerformed", self.owner)
        else
            EventManger:emit("entity.attackPerformed", self.owner)
        end
    end
end

function AttackState:onElapse()
    self.machine:forceState(self.owner.defaultState)
end

function AttackState:onExit()
    self.owner.animator:SetBool(self.animParam,false)
    self.owner.animator.speed = 1
end

--2.HitState
local HitState = Class(TimedState)

function HitState:onEnter()
    TimedState.onEnter(self)
    self.owner.animator:SetBool("isHitting",true)
end

function HitState:getDuration()
    return self.owner.hitDuration
end

function HitState:onElapse()
    self.machine:forceState(self.owner.defaultState)
end

function HitState:onExit()
    self.owner.animator:SetBool("isHitting",false)
end

--3.DeadState
local DeadState = Class(TimedState)

function DeadState:onEnter()
    TimedState.onEnter(self)
    local owner = self.owner
    owner.animator:SetBool("isDead",true)
    owner.isDead = true
    if owner.camp=="enemy" then
        EventManger:emit("enemy.died",self.owner)
    elseif owner.camp=="player" then
        EventManger:emit("player.died",self.owner)
    end
    if owner.deadDuration then
        local pos = owner.go.transform.position
        self.startX = pos.x
        self.startY = pos.y
        self.startZ = pos.z
        local playerX = pos.x
        if owner.chaseTarget and owner.chaseTarget.go then 
            playerX = owner.chaseTarget.go.transfoem.position.x
        end
        local direction = pos.x >= playerX and 1 or -1
        self.targetX = pos.x + direction*(owner.deadRecoil or 0)
    end
end

function DeadState:getDuration()
    return self.owner.deadDuration
end

function DeadState:onTick(dt)
    local owner = self.owner
    if not owner.deadDuration then return end
    local progress = self.timer / owner.deadDuration
    local eased = 1-(1-progress)*(1-progress)
    local x = self.startX + (self.targetX - self.startX)*eased
    owner.go.transform.position = CS.UnityEngine.Vector3(x,self.startY,self.startZ)
end

function DeadState:onElapse()
    local owner = self.owner
    if owner.camp=="enemy" then
        EventManger:emit("enemy.deadFinished",self.owner)
    elseif owner.camp=="pet" then
        EventManger:emit("pet.deadFinished",self.owner)
    end
    
end

--4.KnockbackState
local AttackState = Class(TimedState)

function AttackState:onEnter()
    TimedState.onEnter(self)
    local owner = self.owner
    self.animParam = owner:getAnimParam()
    owner.animator:SetBool(self.animParam,true)
    owner.animator.speed = owner:getAttackSpeed()
    self.hasAttacked = false
end

function AttackState:getDuration()
    return self.owner.getAttackDuration()
end

function AttackState:onTick(dt)
    if self.hasAttacked then return end
    if self.timer >= self.owner:getAttackFrame() then
        self.hasAttacked = true
        if self.owner.getCompactType() == "ranged" then
            EventManger:emit("entity.rangedAttackPerformed", self.owner)
        else
            EventManger:emit("entity.attackPerformed", self.owner)
        end
    end
end

function AttackState:onElapse()
    self.machine:forceState(self.owner.defaultState)
end

function AttackState:onExit()
    self.owner.animator:SetBool(self.animParam,false)
    self.owner.animator.speed = 1
end

--5.StunState
local AttackState = Class(TimedState)

function AttackState:onEnter()
    TimedState.onEnter(self)
    local owner = self.owner
    self.animParam = owner:getAnimParam()
    owner.animator:SetBool(self.animParam,true)
    owner.animator.speed = owner:getAttackSpeed()
    self.hasAttacked = false
end

function AttackState:getDuration()
    return self.owner.getAttackDuration()
end

function AttackState:onTick(dt)
    if self.hasAttacked then return end
    if self.timer >= self.owner:getAttackFrame() then
        self.hasAttacked = true
        if self.owner.getCompactType() == "ranged" then
            EventManger:emit("entity.rangedAttackPerformed", self.owner)
        else
            EventManger:emit("entity.attackPerformed", self.owner)
        end
    end
end

function AttackState:onElapse()
    self.machine:forceState(self.owner.defaultState)
end

function AttackState:onExit()
    self.owner.animator:SetBool(self.animParam,false)
    self.owner.animator.speed = 1
end









-->>>>>>>>>>>>>>>>实体状态机<<<<<<<<<<<<<<