local Component = import("..Component")
local Event = import(".Event")
local EventProtocol = class("EventProtocol", Component)

function EventProtocol:ctor()
    EventProtocol.super.ctor(self, "EventProtocol")
    self.event_list = {}
end

function EventProtocol:AddEventListener(event_name, listener)
    if event_name == nil then
        error("Try to bind to a nil event_name")
        return
    end

    if self.event_list[event_name] == nil then
        self.event_list[event_name] = Event.new(event_name)
    end
    return self.event_list[event_name]:Bind(listener)
end

function EventProtocol:DispatchEvent(event_name, ...)
    if self.event_list[event_name] == nil then return end

    for _, func in pairs(self.event_list[event_name].event_func_list) do
        func(...)
    end
end

function EventProtocol:RemoveEventListener(event_handle)
    if event_handle == nil or event_handle.event_id == nil then
        error("Try to remove a nil event_handle")
        return
    end

    local tmp_event = self.event_list[event_handle.event_id]
    if tmp_event ~= nil then
        tmp_event:UnBind(event_handle)
    end
end

function EventProtocol:RemoveAllEventlist()
    self.event_list = {}
end

function EventProtocol:ExportMethods()
    self:ExportMethods_({
        "AddEventListener",
        "DispatchEvent",
        "RemoveEventListener",
        "RemoveAllEventlist",
    })
end

return EventProtocol