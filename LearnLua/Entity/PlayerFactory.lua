local Class = require ("Class")
local EntityFactory = require ("EntityFactory")
local Player = require ("Player")

local PlayerFactory = Class(EntityFactory)

function PlayerFactory:createEntity(id,configID,config,attributeSet,opts)
    return Player.New(id,configID,config,attributeSet,opts)
end

return PlayerFactory