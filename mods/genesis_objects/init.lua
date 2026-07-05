Genesis = Genesis or {}
Genesis.objects = Genesis.objects or {}
Genesis.objects.items = Genesis.objects.items or {}
Genesis.objects.next_id = Genesis.objects.next_id or 1

function Genesis.objects.create(def)
    local id = Genesis.objects.next_id
    Genesis.objects.next_id = Genesis.objects.next_id + 1

    local obj = {
        id = id,
        object_type = def.object_type or "generic",
        subtype = def.subtype or "unknown",
        name = def.name or ("Object " .. id),

        pos = def.pos or nil,

        state = def.state or {},
        data = def.data or {},

        lifecycle = {
            active = true,
            created = {
                year = Genesis.world.year,
                day = Genesis.world.day,
                tick = Genesis.world.tick
            },
            destroyed = nil
        }
    }

    Genesis.objects.items[id] = obj

    Genesis.log("Object created: #" .. id .. " " .. obj.name .. " [" .. obj.object_type .. "]")
    Genesis.events.emit("object_created", obj)

    return obj
end

function Genesis.objects.get(id)
    return Genesis.objects.items[id]
end

function Genesis.objects.destroy(id, reason)
    local obj = Genesis.objects.items[id]

    if not obj then
        return false
    end

    obj.lifecycle.active = false
    obj.lifecycle.destroyed = {
        year = Genesis.world.year,
        day = Genesis.world.day,
        tick = Genesis.world.tick,
        reason = reason or "unknown"
    }

    Genesis.log("Object destroyed: #" .. id .. " " .. obj.name)
    Genesis.events.emit("object_destroyed", obj)

    return true
end

function Genesis.objects.all()
    return Genesis.objects.items
end

function Genesis.objects.find_by_type(object_type)
    local results = {}

    for _, obj in pairs(Genesis.objects.items) do
        if obj.object_type == object_type and obj.lifecycle.active then
            table.insert(results, obj)
        end
    end

    return results
end

Genesis.events.on("simulation_started", function(saved_state)
    if saved_state and saved_state.objects then
        Genesis.objects.items = saved_state.objects.items or {}
        Genesis.objects.next_id = saved_state.objects.next_id or 1
        Genesis.log("Objects restored from save")
    end
end)

Genesis.log("Genesis Objects v0.1 loaded")
