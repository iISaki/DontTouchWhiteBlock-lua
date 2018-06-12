local Dialog = class("Dialog", function()
    return display.newNode()
end)

function Dialog:ctor(desc, scene, color, path)    
    self.layerColor = cc.LayerColor:create(color, display.width / 2, display.height / 3)
    self.layerColor:setPosition(display.width / 4, display.height / 3)
    self.layerColor:setOpacity(0)
    self:addChild(self.layerColor)
    
    self.scene = scene

    local icon = path or "yq_BG1.png"
    self.bg = cc.Sprite:create(icon)
    -- self.bg:setContentSize(display.center)
    self.layerColor:addChild(self.bg)
    self.bg:setPosition(self.layerColor:getContentSize().width / 2, self.layerColor:getContentSize().height / 2)
    -- self:setContentSize(display.size)
    
    self.desc = cc.Label:createWithSystemFont("", "Arial", 30)
    self.desc:setColor(cc.BLACK)
    self.desc:setPosition(self.layerColor:getContentSize().width / 2, self.layerColor:getContentSize().height / 2 + 50)
    -- self.desc:setDimensions(Size(self.layerColor:getContentSize().width - 10, self.layerColor:getContentSize().height - 10))
    self.desc:setString(desc)
    self.layerColor:addChild(self.desc)

    self:CreateButton()
    self:OnTouchEvent()
end

function Dialog:CreateButton()
    self.sureBtn = ccui.Button:create("btn_huang.png")
    self.sureBtn:setPosition(self.layerColor:getContentSize().width / 2 - 100, self.layerColor:getContentSize().height / 2 - 50)
    self.sureBtn:setTitleText("重来")
    self.sureBtn:getTitleRenderer():setSystemFontSize(30)
    self.sureBtn:addClickEventListener(function(event)
        self:OnButtonClick(1)
    end)
    self.layerColor:addChild(self.sureBtn)
    
    self.exitBtn = ccui.Button:create("btn_blue.png")
    self.exitBtn:setPosition(self.layerColor:getContentSize().width / 2 + 100, self.layerColor:getContentSize().height / 2 - 50)
    self.exitBtn:setTitleText("退出")
    self.exitBtn:getTitleRenderer():setSystemFontSize(30)
    self.exitBtn:addClickEventListener(function(event)
        self:OnButtonClick(2)
    end)
    self.layerColor:addChild(self.exitBtn)
end

function Dialog:OnTouchEvent()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event)
            return true--返回true时，该层下面的层的触摸事件都会屏蔽掉
    end,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function Dialog:OnButtonClick(event)
    if event == 1 then 
        self.scene:restart()
    else 
        local scene = self.scene:getApp():getSceneWithName("MainScene")
        cc.Director:getInstance():replaceScene(scene)
    end
    self:removeFromParent()
end

return Dialog