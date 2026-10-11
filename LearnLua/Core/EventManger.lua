local Class = require("Class")
local EventConfig = require("EventConfig")


local EventManger = Class()

local listener = {} --cb,owner,event,dead
local dispatchDepth = 0
local pendingCompact = false

local function checkDeclared(eventName, action)
    if EventConfig.eventName then return true end
    print(string.format("[EventManger]%s了未声明的事件：%s",action,tostring(eventName)))
    return false
end

local function compact(eventName)

    local function purge(list)
        for i=#list,1,-1 do
            local e = list[i]
            if e.dead then
                table.remove(list,i)
            end
        end
    end

    if eventName then
        local list = listener[eventName]
        if list then purge(list) end
        return
    end
    for _, list in pairs(listener) do purge(list) end
end

function EventManger:on(eventName, cb, owner)
    if not checkDeclared(eventName,"订阅") then return nil end
    local list = listener[eventName]
    if not list then
        list = {}
        listener[eventName] = list
    end

    local entry = {cb = cb, owner = owner, event = eventName}
    table.insert(list,entry)
    return entry
end

function EventManger:off(handleOrName, cb) --entry单参数或者事件名字+cb做参数
    local entry
    if type(handleOrName)==table then
        entry = handleOrName
    else
        local list = listener[handleOrName]
        if not list then return end

        for i=1,#list do
            local e = list[i]
            if not e.dead and e.cb==cb then
                entry = e
                break
            end
        end
    end

    if not entry or entry.dead then return end
    entry.dead = true

    if dispatchDepth > 0 then
        pendingCompact = true;
    else
        compact(entry.event);
    end
end


function EventManger:offOwner(owner)
    if not owner then return end
    for _, list in pairs(listener) do
        for i=1,#list do
            local e = list[i]
            if not e.dead and e.owner==owner then
                e.dead=true
            end
        end
    end

    if dispatchDepth > 0 then
        pendingCompact = true;
    else
        compact();
    end

end


function EventManger:emit(eventName,...)
    if not checkDeclared(eventName,"发射") then return end

    local list = listener[eventName]
    if not list then return end

    local count = #list
    if count == 0 then return end

    dispatchDepth = dispatchDepth + 1
    for i = 1,#list do
        local entry = list[i]
        if entry and not entry.dead then
            local ok, err = pcall(entry.cb, ...)
            if not ok then
                print(string.format("[EventManger]事件%s的第%d个回调报错：%s",eventName,i,tostring(err)))
            end
        end
    end
    dispatchDepth = dispatchDepth - 1

    if dispatchDepth==0 and pendingCompact then
        pendingCompact = false
        compact();
    end
end


return EventManger