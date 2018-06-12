local Block = import(".Block")
local Dialog = import(".Dialog")
local TouchNumScene = class("TouchNumScene", cc.load("mvc").ViewBase)

math.randomseed(os.time())

function TouchNumScene:onCreate()
    self.timerLabel = cc.Label:createWithSystemFont("0.00s", "Arial", 60)
    self.timerLabel:setPosition(display.width / 2, display.height - 100)
    self.timerLabel:setColor(cc.BLUE)
    self.timerLabel:setZOrder(999)
    self:setTouchEvent()
    self:initData()
    self:startGame()
    self:addChild(self.timerLabel)

    local f = io.open("src/recordNum.lua", "r")
    if nil ~= f then
        f:close()
        package.loaded["src/recordNum"] = nil
        local data = require("src/recordNum")
        print('TouchNumScene >>>>> line = 32', data);
        self.record = data
    end
    self.record = 0
end

function TouchNumScene:initData()
    self.blocks = {}
    self.isStart = false
    -- self.showEndLine = false
    -- self.timer = 0
    self.canTouchIdx = 1
    self.touchNum = 0
    -- self.isEndLine = false
    self.time = 0
    self.speed = 0
    self.timerLabel:setString("0")
    self.schedulerID = nil
end

function TouchNumScene:ShowDialog(desc, color)
    local dialog = Dialog.new(desc, self, color)
    self:addChild(dialog)
end

function TouchNumScene:setTouchEvent()
    local layer = display.newNode()
    layer:setContentSize(display.width, display.height)
    
    local function onTouchBegin(touch, event)
        local locationInNode = self:convertToNodeSpace(touch:getLocation())
        for k,v in pairs(self.blocks) do
            if v:GetLineIndex() == self.canTouchIdx and cc.rectContainsPoint(v:getBoundingBox(), locationInNode) then 
                if not self.isStart then 
                    self.isStart = true
                    local scheduler = cc.Director:getInstance():getScheduler()
                    self.schedulerID = scheduler:scheduleScriptFunc(function()  
                        self:MoveDown()
                    end, 0, false)
                end
                local color = v:getColor()
                if cc.BLACK.r == color.r and cc.BLACK.g == color.g and cc.BLACK.b == color.b then 
                    self.touchNum = self.touchNum + 1
                    self.canTouchIdx = self.canTouchIdx + 1
                    -- self:MoveDown()
                    v:SetColor(cc.BLUE)
                    self.timerLabel:setString(self.touchNum)
                else
                    -- if cc.GREEN.r == color.r and cc.GREEN.g == color.g and cc.GREEN.b == color.b then
                    --     -- self:MoveDown()
                    --     v:SetColor(cc.RED)
                    --     self:ShowDialog("是否重新开始", cc.YELLOW)
                    -- else 
                    -- end
                    print('TouchNumScene >>>>> line = 76', self.touchNum, self.record);
                    if self.touchNum > self.record then 
                        self.record = self.touchNum
                        local f = io.open("src/recordNum.lua", "w")
                        local str = string.format( "return %s", self.touchNum)
                        print('TouchNumScene >>>>> line = 85', str);
                        f:write(str)
                        f:close()
                    end
                    self:ShowDialog("记录：" .. self.record, cc.YELLOW)
                    self.isStart = false
                    if self.schedulerID then 
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
                        self.schedulerID = nil
                    end 
                    self.touchNum = 0
                end
            end
        end
        return true
    end
    local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(true);
    listener:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN);
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer);
    
    self:addChild(layer)
end

function TouchNumScene:startGame()
    self:addStartLine()
    self:addNormalLine(1)
    self:addNormalLine(2)
    self:addNormalLine(3)
    self:addNormalLine(4)
end

function TouchNumScene:restart()
    self:initData()
    self:startGame()
end

function TouchNumScene:addStartLine()
    local block = Block.new(cc.YELLOW, {width = display.width , height = display.height / 4}, "start game")
    block:SetLineIndex(0)
    block:setPosition(0, 0)
    self:addChild(block)
    table.insert(self.blocks, block)
end

function TouchNumScene:addNormalLine(index, height)
    local rand = math.random(0, 3)
    for i = 0,3 do
        local block = Block.new(rand == i and cc.BLACK or cc.WHITE, {width = display.width / 4 - 1, height = display.height / 4 - 1})
        block:SetLineIndex(index)
        local h = height or display.height / 4 * index
        block:setPosition(display.width / 4 * i , h)
        self:addChild(block)
        table.insert(self.blocks, block)
    end
end

function TouchNumScene:addEndLine()
    local block = Block.new(cc.GREEN, {width = display.width , height = display.height}, "Game Over")
    block:SetLineIndex(4)
    block:setPosition(0, display.height)
    self:addChild(block)
    table.insert(self.blocks, block)
end

function TouchNumScene:MoveDown()
    self.time = self.time + 1
    if self.time % 100 == 0 then 
        self.speed = self.speed + 2
        self.time = 0
    end
    local maxHeight = 0
    -- print('TouchNumScene >>>>> line = 140', #self.blocks);
    for k,v in pairs(self.blocks) do
        local x, y = v:getPosition()
        y = y - (10 + self.speed)
        v:setPosition(x, y)
        if maxHeight < y then 
            maxHeight = y
        end
        local color = v:getColor()
        if y < 0 and cc.BLACK.r == color.r and cc.BLACK.g == color.g and cc.BLACK.b == color.b then 
            self:ShowDialog("记录：" .. self.record, cc.YELLOW)
            if self.touchNum > self.record then 
                self.record = self.touchNum
                local f = io.open("src/recordNum.lua", "w")
                local str = string.format( "return %s", self.touchNum)
                f:write(str)
                f:close()
            end
            if self.schedulerID then 
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
                self.schedulerID = nil
            end 
            return 
        end
    end
    if maxHeight < display.height / 4 * 3 then 
        local blocks = {}
        local x, y = 0, 0
        for k,v in pairs(self.blocks) do
            v:MoveDownNum()
            if v.GetLineIndex and v:GetLineIndex() >= 0 then 
                if v:GetLineIndex() == 3 then 
                    x, y = v:getPosition()
                end
                table.insert(blocks, v)
            end
        end
        self.blocks = blocks
        self.canTouchIdx = self.canTouchIdx - 1
        self:addNormalLine(4, y + display.height / 4)
    end
end

return TouchNumScene