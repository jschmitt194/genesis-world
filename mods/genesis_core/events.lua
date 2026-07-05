Genesis = Genesis or {}
Genesis.events = Genesis.events or {}
Genesis.events.listeners = Genesis.events.listeners or {}

function Genesis.events.on(event_name, callback)
    Genesis.events.listeners[event_name] = Genesis.events.listeners[event_name] or {}
    table.insert(Genesis.events.listeners[event_name], callback)
    Genesis.log("Listener registered for event: " .. event_name)
end

function Genesis.events.emit(event_name, data)
    local listeners = Genesis.events.listeners[event_name]

    if not listeners then
        return
    end

    for _, callback in ipairs(listeners) do
        callback(data)
    end
end
