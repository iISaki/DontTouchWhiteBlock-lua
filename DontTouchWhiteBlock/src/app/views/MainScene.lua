function PrintTable(tbl, level)
	if nil == tbl or "table" ~= type(tbl) then
		print("[PrintTable] arg is nil or not a table!!!")
		return
	end

	level = level or 1

	local indent_str = ""
	for i = 1, level do
		indent_str = indent_str.."  "
	end

	print(indent_str .. "{")
	for k,v in pairs(tbl) do
		local item_str = string.format("%s%s = %s", indent_str .. "  ", tostring(k), tostring(v))
		print(item_str)
		if type(v) == "table" then
			PrintTable(v, level + 1)
		end
	end
	print(indent_str .. "}")
end

local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
    local bg = cc.Sprite:create("main_bg.png")
    :move(display.center)
    :addTo(self)
    -- bg:setContentSize({width = display.width, height = display.height})
    -- bg:setPosition(display.center)
    local size = bg:getContentSize()
    local scale_x = display.width / size.width
    local scale_y = display.height / size.height
    bg:setScale(scale_x, scale_y)
    -- self:addChild(bg)
    -- print('MainScene >>>>> line = 9', size.width, size.height);
    self:CreateButton()
end

function MainScene:CreateButton()
    self.sureBtn = ccui.Button:create("btn_2_1.png", "btn_2_2.png")
    self.sureBtn:setPosition(display.width / 2, display.height / 2 - 100)
    self.sureBtn:setTitleText("竞速")
    self.sureBtn:getTitleRenderer():setSystemFontSize(25)
    -- self.sureBtn:addTouchEventListener(function(sender, state)
    --     self:OnButtonClick(sender, state)
    -- end)
    self.sureBtn:addClickEventListener(function(event)
        self:OnButtonClick(1)
    end)
    self:addChild(self.sureBtn)
    
    self.exitBtn = ccui.Button:create("btn_2_1.png", "btn_2_2.png")
    self.exitBtn:setPosition(display.width / 2, display.height / 2 + 100)
    self.exitBtn:setTitleText("竞数")
    self.exitBtn:getTitleRenderer():setSystemFontSize(25)
    -- self.exitBtn:addTouchEventListener(function(sender, state)
    --     self:OnButtonClick(sender, state)
    -- end)
    self.exitBtn:addClickEventListener(function(event)
        self:OnButtonClick(2)
    end)
    self:addChild(self.exitBtn)
end

function MainScene:OnButtonClick(event)
    local scene = nil
    if event == 1 then 
        scene = self:getApp():getSceneWithName("TouchNumScene")
    else 
        scene = self:getApp():getSceneWithName("TouchSpeedScene")  
    end
    cc.Director:getInstance():replaceScene(scene)
end

return MainScene