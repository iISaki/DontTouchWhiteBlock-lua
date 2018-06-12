local EventDispatcher = import("..components.behavior.EventDispatcher")
local Block = class("Block", function ()
    return display.newNode()
end)

Block.numLabel = nil
Block.layerCol = nil
Block.lineIndex = 0
Block.Instance = nil

Block.REMOVE_EVENT = "REMOVE_EVENT"

function Block:ctor(blockColor, size, labelStr, fontSize, textColor)
    self.layerCol = cc.LayerColor:create(blockColor, size.width, size.height)
    self:setColor(blockColor)
    self.numLabel = cc.Label:createWithSystemFont(labelStr, "Arial", 40)
    self.numLabel:setPosition(self.layerCol:getContentSize().width / 2, self.layerCol:getContentSize().height / 2)
    -- self.numLabel:setColor(cc.BLACK)
    self.layerCol:addChild(self.numLabel)
    self:addChild(self.layerCol)
    self:setContentSize(size)
end

function Block:SetLineIndex(index)
    self.lineIndex = index
end

function Block:GetLineIndex()
    return self.lineIndex
end

function Block:SetColor(color)
    self.layerCol:setColor(color)
    self:setColor(color)
end

function Block:removeBlock()
    self:removeFromParent()
    EventDispatcher.Instance:dispatchEvent(Block.REMOVE_EVENT, 1)
end

function Block:MoveDown()
    self.lineIndex = self.lineIndex - 1
    local move = cc.MoveBy:create(0.1, cc.p(0, - display.height / 4))
    local callback = cc.CallFunc:create(function()
        if self.lineIndex < 0 then 
            self:removeBlock()
        end
    end)
    self:runAction(cc.Sequence:create(move, callback))
end

function Block:MoveDownNum()
    self.lineIndex = self.lineIndex - 1
    if self.lineIndex < 0 then 
        self:removeBlock()
    end
end

return Block