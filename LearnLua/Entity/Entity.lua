local Class = require("Class")

local Entity = Class()

function Entity:_Init(id,configID,config,attributeSet)
    --1.身份
    self.id = id
    self.configID = configID
    self.camp = config.camp
    self.isBoss = config.isBoss or false
    --2.属性
    self.attributeSet = attributeSet
    --3.行为参数（来自配置表）
    self.moveSpeed = config.moveSpeed
    self.attackRange = config.attackRange --远程的攻击范围，近战直接Collider
    self.attackFrame = config.attackFrame
    self.attackDuration = config.attackDuration --攻击动画持续时长
    self.hitDuration = config.hitDuration --受击动画持续时长
    self.defaultState = config.defaultState

    --4.运行时状态
    self.hasTarget = false
    self.deadDuration = config.deadDuration
    self.chaseTarget = nil
    --5.技能
    
end

function Entity:getAttackFrame()
    return self.attackFrame
end

function Entity:getAttackDuration()
    return self.attackDuration
end


function Entity:getCompactType()
    --TODO
end

function Entity:getAnimParam()
    --TODO
end

function Entity:getAttackSpeed()
    --TODO
end

return Entity