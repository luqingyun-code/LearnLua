local Class = require("Class")
local Stats = require("Stats")
local EntityConfig = require("EntityConfig")

local EntityFactory = Class()

EntityFactory._nextId = 0

local function genId()
    EntityFactory._nextId = EntityFactory._nextId + 1
    return EntityFactory._nextId
end

function EntityFactory.resetIdCounter(starId)
    EntityFactory._nextId = starId or 0
end


function EntityFactory:create(configID,opts)
    local id = genId()
    local config = EntityConfig[configID]
    local attributeSet = Stats.AttributeSet.New(config.attributes)
    local entity = self:createEntity(id,configID,config,attributeSet,opts)
    if not entity then
        error("[EntityFactory] 创建实体函数没返回实体，创建失败")
    end
end

function EntityFactory:createEntity(id,config,configId,attributeSet,opts)
    error("[EntityFactory] 调用基类")
end

return EntityFactory