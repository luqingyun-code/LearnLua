local Class = require("Class")
local ResourceManager = require("ResourceManager")
local UILayer = require("UILayer")

local UIManager = Class()

local function removeFrom(list, value)
    for i = #list, 1, -1 do
        if list[i] == value then
            table.remove(list, i)
            return
        end
    end
end

function UIManager:init(uiRegistry, layerConfig, rootGO)
    self.registry = uiRegistry
    self.panels = {}
    self.modalStack = {}
    self.updateList = {}
    UILayer:init(layerConfig, rootGO)
end

function UIManager:createPanel(name, cfg)
    local layerRoot = UILayer:get(cfg.layer)
    if not layerRoot then
        print("[UIManager] 层级不存在")
        return nil
    end
    local go
    if cfg.prefab then
        go = ResourceManager:instantiate(cfg.prefab, layerRoot)
        if not go then
            print()
            return nil
        end
        go.name = name
    else
        print("[UIManager] 面板预制体路径有误")
        return nil
    end
    local ok, panelClass = pcall(require, cfg.script)
    if not panelClass then
        print()
        return nil
    end
    return panelClass.New(go,name,cfg,function() self:close() end)
end

function UIManager:open(name,params)
    local cfg = self.registry and self.registry[name]
    if not cfg then
        print()
        return nil
    end
    local inst = self.panels[name]
    if not inst then
        inst = self:createPanel(name,cfg)
        if not inst then return nil end
        self.panels[name] = inst
    end
    if inst._visible then return inst end
    inst.go:SetActive(true)
    inst.transform:SetAsLastSibling()
    inst._visible = true
    inst:onShow(params)

    if cfg.modal then table.insert(self.modalStack, name) end
    if inst.needUpdate then table.insert(self.updateList, inst) end
    return inst
end

function UIManager:close(name)
    local inst = self.panels[name]
    if not inst then
        print("要关闭的面板不存在")
        return
    end
    if not inst._visible then return end
    inst._visible = false
    inst:onHide()
    removeFrom(self.modalStack, name)
    removeFrom(self.updateList, inst)
    local cfg = inst._cfg
    if cfg.cache == false then
        inst:onDestroy()
        if cfg.prefab then
            CS.UnityEngine.GameObject.Destory(inst.go)
        else
            inst.go:SetActive(false)
        end
        self.panels[name] = nil
    else
        inst.go:SetActive(false)
    end
end

function UIManager:closeTop()
    local top = self.modalStack[#self.modalStack]
    if top then self:close(top) end
    return top
end

function UIManager:closeAll(layer)
    for name, inst in pairs(self.panels) do
        if inst._visible and (layer == nil or inst._cfg.layer == layer) then
            self:close(name)
        end
    end
end

function UIManager:get(name)
    return self.panels[name]
end

function UIManager:isOpen(name)
    local inst = self.panels[name]
    return inst ~= nil and inst._visible == true
end

function UIManager:hasModel()
    return #self.modalStack > 0
end

function UIManager:update(dt)
    for i = #self.updateList, 1, -1 do
        local inst = self.updateList[i]
        if inst then inst:onUpdate(dt) end
    end
end

return UIManager.New()