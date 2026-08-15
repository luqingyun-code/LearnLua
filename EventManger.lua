local Class = require("Class")


local EventManger = Class()

local listener = {} --key:eventName,  value:cb

function EventManger:on(eventName, owner, cb)
    if not listener[eventName] then
        listener[eventName] = {}
    end

    for _, group in pairs(listener[eventName]) do
        if group["owner"] == owner then
            table.insert(group["callback"], cb)
            return
        end
    end

    table.insert(listener[eventName],{owner = owner,callback = {cb}})
end

function EventManger:off(eventName, owner, cb)
    if not listener[eventName] then
        return
    end

    for _, group in ipairs(listener[eventName]) do
        if group["owner"] == owner then
            for i = #group["callback"],1,-1 do
                if group["callback"][i] == cb then
                    table.remove(group["callback"], i)
                    break
                end
            end
        end
    end

end


function EventManger:offAll(owner)
    for eventName, groups in pairs(listener) do
        for i = #groups,1,-1 do
            if groups[i]["owner"] == owner then
                table.remove(groups,i)
            end
        end
    end
end


function EventManger:emit(eventName,...)
    if not listener[eventName] then
        return
    end

    local callbacks = {}

    for _, group in ipairs(listener[eventName]) do
        for _, callback in ipairs(group["callback"]) do
            table.insert(callbacks, callback)
        end
        
    end

    for _, cb in ipairs(callbacks) do
        cb(...)
    end
end


return EventManger