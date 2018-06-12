local GameObject = {}

function GameObject.Extend(target)
    target.components = {}

    function target:CheckComponent(class_ref)
        return self.components[class_ref] ~= nil
    end

    function target:AddComponent(class_ref)
        local component = class_ref.new()
        self.components[class_ref] = component
        component:bind(self)
        return component
    end

    function target:RemoveComponent(class_ref)
        local component = self.components[class_ref]
        if component then component:unBind() end
        self.components[class_ref] = nil
    end

    function target:GetComponent(class_ref)
        return self.components[class_ref]
    end

    return target
end

-- local Registry = import(".Registry")

-- local GameObject = {}

-- function GameObject.extend(target)
--     target.components_ = {}

--     function target:checkComponent(name)
--         return self.components_[name] ~= nil
--     end

--     function target:addComponent(name)
--         local component = Registry.newObject(name)
--         self.components_[name] = component
--         component:bind_(self)
--         return component
--     end

--     function target:removeComponent(name)
--         local component = self.components_[name]
--         if component then component:unbind_() end
--         self.components_[name] = nil
--     end

--     function target:getComponent(name)
--         return self.components_[name]
--     end

--     return target
-- end

return GameObject