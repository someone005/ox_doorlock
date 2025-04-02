local hooks = setmetatable({}, {
    __index = function(self, k)
        self[k] = {}
        return self[k]
    end
})
local hookId = 0

function TriggerHook(event, payload)
    local callbacks = hooks[event]
    if not callbacks then return end

    local response = nil

    for _, callback in ipairs(callbacks) do
        local success, result = pcall(callback, payload)
        if not success then
            print(('Error in hook %s: %s'):format(event, result))
        end

        if result ~= nil then
            response = result
        end
    end

    return response
end

function registerHook(event, callback)
    local mt = getmetatable(callback)
    mt.__index = nil
    mt.__newindex = nil
    callback.resource = GetInvokingResource()
    hookId = hookId + 1
    callback.hookId = hookId
    hooks[event][#hooks[event] + 1] = callback

    return hookId
end

exports('registerHook', registerHook)

function removeResourceHook(resource, hookId)
    for event, callbacks in pairs(hooks) do
        for i = #callbacks, 1, -1 do
            local callback = callbacks[i]
            if callback.resource == resource or hookId and callback.hookId == hookId then
                table.remove(hooks[event], i)
            end
        end
    end
end

AddEventHandler('onResourceStop', removeResourceHook)
exports('removeResourceHook', removeResourceHook)