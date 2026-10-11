local M = {}
function M.New(Base)
    local Class = {}
    Class.__index = Class
    if Base then
        setmetatable(Class,Base)
    end
    Class.New = function (...)
        local obj = setmetatable({}, Class)
        if Class._Init then
            Class._Init(obj,...)
        end
        return obj
    end
    return Class
end

return M.New