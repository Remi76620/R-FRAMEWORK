local registeredCallbacks = {}

local function validateCallbackArguments(cbName, func)
    return type(cbName) == "string" and type(func) == "function"
end

--- Registers a server callback.
--- @param cbName string The name of the callback to register
--- @param func function The function to call when the callback is triggered
function rm.RegisterServerCallback(cbName, func)
    if not validateCallbackArguments(cbName, func) then
        rm.Io.Error("Invalid arguments to RegisterServerCallback.")
        return
    end

    if registeredCallbacks[cbName] then
        rm.Io.Error("Callback already registered: " .. cbName)
        return
    end

    registeredCallbacks[cbName] = func
    rm.Io.Trace("Registered server callback: " .. cbName)
end

RegisterNetEvent("rm-framework:triggerServerCallback", function(cbName, requestId, invoker, ...)
    local callback = registeredCallbacks[cbName]
    if not callback then
        rm.Io.Error("Callback not registered: " .. cbName)
        return
    end

    local _source = source

    callback(_source, function(...)
        TriggerClientEvent('rm-framework:serverCallback', _source, requestId, invoker, ...)
    end, ...)
end)

