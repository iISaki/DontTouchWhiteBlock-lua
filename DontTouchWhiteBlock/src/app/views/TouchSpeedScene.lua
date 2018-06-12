
local Block = import(".Block")
local Dialog = import(".Dialog")
local EventDispatcher = import("..components.behavior.EventDispatcher")
local TouchSpeedScene = class("TouchSpeedScene", cc.load("mvc").ViewBase)

math.randomseed(os.time())

function TouchSpeedScene:onCreate()
    EventDispatcher.Instance:addEvent("REMOVE_EVENT", function (key)
        self:RemoveBlock(key)
    end)
    
    self.timerLabel = cc.Label:createWithSystemFont("0.00s", "Arial", 60)
    self.timerLabel:setPosition(display.width / 2, display.height - 100)
    self.timerLabel:setColor(cc.BLUE)
    self.timerLabel:setZOrder(999)
    self:setTouchEvent()
    self:initData()
    self:startGame()
    self:addChild(self.timerLabel)
    local f = io.open("src/record.lua", "r")
    if nil ~= f then
        f:close()
        package.loaded["src/record"] = nil
        local data = require("src/record")
        print('TouchSpeedScene >>>>> line = 32', data);
        self.record = data
    end
end

function TouchSpeedScene:initData()
    self.blocks = {}
    self.isStart = false
    self.showEndLine = false
    self.timer = 0
    self.touchNum = 0
    self.isEndLine = false
    self.record = 5000
    self.timerLabel:setString("0.00s")
    self.schedulerID = nil
end

function TouchSpeedScene:ShowDialog(desc, color)
    local dialog = Dialog.new(desc, self, color)
    self:addChild(dialog)
end

function TouchSpeedScene:setTouchEvent()
    local layer = display.newNode()
    layer:setContentSize(display.width, display.height)
    
    local function onTouchBegin(touch, event)
        local locationInNode = self:convertToNodeSpace(touch:getLocation())
        for k,v in pairs(self.blocks) do
            -- local nodeBox = self.block:getBoundingBox()
            if v:GetLineIndex() == 1 and cc.rectContainsPoint(v:getBoundingBox(), locationInNode) then 
                -- print('TouchSpeedScene >>>>> line = 30', v:getColor().r, v:getColor().g, v:getColor().b)
                -- print('TouchSpeedScene >>>>> line = 30', cc.BLACK.r, cc.BLACK.g, cc.BLACK.b)
                -- print('TouchSpeedScene >>>>> line = 30', cc.BLACK == v:getColor())

                if not self.isStart then 
                    self.isStart = true
                    local scheduler = cc.Director:getInstance():getScheduler()
                    self.schedulerID = scheduler:scheduleScriptFunc(function()  
                        self:TimerStr()
                    end, 0, false)
                end
                local color = v:getColor()
                if cc.BLACK.r == color.r and cc.BLACK.g == color.g and cc.BLACK.b == color.b then 
                    self.touchNum = self.touchNum + 1
                    self:MoveDown()
                    v:SetColor(cc.BLUE)
                else
                    if cc.GREEN.r == color.r and cc.GREEN.g == color.g and cc.GREEN.b == color.b then
                        self:MoveDown()
                        print('TouchSpeedScene >>>>> line = 82', self.timer, self.record);
                        if self.timer < self.record then 
                            self.record = self.timer
                            local f = io.open("src/record.lua", "w")
                            local str = string.format( "return %s", self.timer)
                            print('TouchSpeedScene >>>>> line = 85', str);
                            f:write(str)
                            f:close()
                        end
                        self:ShowDialog("记录：" .. string.format("%.2f", self.record / 100) .. "s", cc.YELLOW)
                    else 
                        v:SetColor(cc.RED)
                        self:ShowDialog("是否重新开始", cc.YELLOW)
                    end
                    self.isStart = false
                    if self.schedulerID then 
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
                        self.schedulerID = nil
                    end 
                    self.timer = 0
                end
            end
        end
        return true
    end
    -- local function onTouchMoved(touch, event)
    --     local locationInNode = self:convertToNodeSpace(touch:getLocation())
    -- end
	-- local function onTouchEnd(touch, event)
	-- 	local locationInNode = self:convertToNodeSpace(touch:getLocation())
	-- 	self:onTouch("ended", locationInNode.x, locationInNode.y)
    -- end
    local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(true);
    listener:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN);
    -- listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED);
    -- listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED);
    -- listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED);
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer);
    
    self:addChild(layer)
end

function TouchSpeedScene:startGame()
    self:addStartLine()
    self:addNormalLine(1)
    self:addNormalLine(2)
    self:addNormalLine(3)
end

function TouchSpeedScene:restart()
    self:initData()
    self:startGame()
end

function TouchSpeedScene:addStartLine()
    local block = Block.new(cc.YELLOW, {width = display.width , height = display.height / 4}, "start game")
    block:SetLineIndex(0)
    block:setPosition(0, 0)
    self:addChild(block)
    table.insert(self.blocks, block)
end

function TouchSpeedScene:addNormalLine(index)
    local rand = math.random(0, 3)
    for i = 0,3 do
        local block = Block.new(rand == i and cc.BLACK or cc.WHITE, {width = display.width / 4 - 1, height = display.height / 4 - 1})
        block:SetLineIndex(index)
        block:setPosition(display.width / 4 * i , display.height / 4 * index)
        self:addChild(block)
        table.insert(self.blocks, block)
    end
end

function TouchSpeedScene:addEndLine()
    local block = Block.new(cc.GREEN, {width = display.width , height = display.height}, "Game Over")
    block:SetLineIndex(4)
    block:setPosition(0, display.height)
    self:addChild(block)
    table.insert(self.blocks, block)
end

function TouchSpeedScene:TimerStr()
    self.timer = self.timer + 1
    self.timerLabel:setString(string.format("%.2f", self.timer / 100) .. "s")
end

function TouchSpeedScene:MoveDown()
    if self.touchNum < 20 then 
        self:addNormalLine(4)
    elseif not self.isEndLine then 
        self.isEndLine = true
        self:addEndLine()
    end 
    for k,v in pairs(self.blocks) do
        v:MoveDown()
    end
    local blocks = {}
    for k,v in pairs(self.blocks) do
        if v:GetLineIndex() >= 0 then 
            table.insert(blocks, v)
        end
    end
    self.blocks = blocks
end

function TouchSpeedScene:RemoveBlock(key)
    -- print('TouchSpeedScene >>>>> line = 158', key);
end

return TouchSpeedScene
