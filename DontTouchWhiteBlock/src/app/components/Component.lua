local Component = class("Component")

function Component:ctor(name, depends)
    self.name = name
    -- self.depends = checktable(depends)
    self.depends = depends or {}
end

function Component:getName()
    return self.name
end

function Component:getDepends()
    return self.depends
end

function Component:getTarget()
    return self.target
end

function Component:ExportMethods_(methods)
    self.exportedMethods = methods
    local target = self.target
    local com = self
    for _, key in ipairs(methods) do
        if not target[key] then
            local m = com[key]
            target[key] = function(__, ...)
                return m(com, ...)
            end
        end
    end
    return self
end

function Component:bind(target)
    self.target = target
    for _, name in ipairs(self.depends) do
        if not target:checkComponent(name) then
            target:addComponent(name)
        end
    end
    self:onBind(target)
end

function Component:unbind()
    if self.exportedMethods then
        local target = self.target
        for _, key in ipairs(self.exportedMethods) do
            target[key] = nil
        end
    end
    self:onUnbind()
end

function Component:onBind()
end

function Component:onUnbind()
end

return Component