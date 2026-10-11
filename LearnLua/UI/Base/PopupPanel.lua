local Class = require("Class")
local UIPanel = require("UIPanel")

local PopupPanel = Class(UIPanel)

--字段
--go,transform,rectTransform,name,_cfg,_closeSelf
function PopupPanel:_Init(self,go,name,cfg,closeSelf)
    UIPanel._Init(self,go,name,cfg,closeSelf)
    self.pathMask = nil
    self.pathClose = "Window/TopBar/CloseButton"
    self.closeOnMask = true
end

function PopupPanel:onShow(params)
    
end

function PopupPanel:onHide()
    
end

--只调用一次，绑关闭按钮+遮罩点击
function PopupPanel:onCreate()
    if self.pathClose then
        self:bindButton(self.pathClose, function() self:close() end)
    end

    if self.closeOnMask and self.pathMask then
        local btn = self:comp(self.pathMask, typeof(CS.UnityEngine.UI.Button))
        if btn then
            btn.onClick:AddListener(function() self:close() end)
        end
    end
end

return PopupPanel