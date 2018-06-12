local EventDispatcher = {}  
EventDispatcher.__index = EventDispatcher  
  
--实例  
function EventDispatcher:new()  
    local store = nil
    if store then return store end  
    local o =  {}  
    setmetatable(o, self)  
    self.__index = self  
    store = o  
    self.m_listeners = {}
    return o  
    -- return function()  
    -- end  
end  
  
--单例  
EventDispatcher.Instance = EventDispatcher:new()
  
--注册  
function EventDispatcher:addEvent(name,listener)  
    -- 先看看事件是否存在  
    local index = 1
    if self.m_listeners[name] == nil then  
        self.m_listeners[name] = {}
    else  
        local existIndex = self:getEventIndex(name,listener)  
        if existIndex ~= -1 then  
            return  
        end  
        index = #self.m_listeners[name] + 1                              --存在下标，则下标+1，用于赋值新事件  
    end  
    --cclog("EventDispatcher:addEvent %s,index = %d",name,index)  
    self.m_listeners[name][index] = listener                             --key赋值事件  
end  
  
--注销  
function EventDispatcher:removeEvent(name,listener)  
    if self.m_listeners[name] == nil then  
        return  
    end  
    local existIndex = self:getEventIndex(name,listener)  
    if existIndex == -1 then return end  
    table.remove(self.m_listeners[name],existIndex)  
end  
  
--派发  
function EventDispatcher:dispatchEvent(name,...)  
    if self.m_listeners[name] == nil then  
        return  
    end  
    for k,v in pairs(self.m_listeners[name]) do                           --单个key对应多个事件  
        v(...)  
    end      
end  
  
--检查事件下标，没有则返回-1  
function EventDispatcher:getEventIndex(name,listener)  
    if self.m_listeners[name] == nil then  
        return -1  
    end  
    for i=1,#self.m_listeners[name] do  
        if self.m_listeners[name][i] == listener then  
            return i  
        end  
    end  
    return -1  
end  
  
return EventDispatcher