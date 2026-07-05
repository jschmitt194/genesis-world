Genesis = Genesis or {}
Genesis.objects = Genesis.objects or {}

Genesis.objects.items = Genesis.objects.items or {}
Genesis.objects.next_id = Genesis.objects.next_id or 1

Genesis.objects.region_size = 16
Genesis.objects.regions = Genesis.objects.regions or {}

function Genesis.objects.region_key(rx, rz)
    return tostring(rx) .. "," .. tostring(rz)
end

function Genesis.objects.get_region_coords(pos)
    if not pos then
        return nil, nil
    end

    local rx = math.floor(pos.x / Genesis.objects.region_size)
    local rz = math.floor(pos.z / Genesis.objects.region_size)

    return rx, rz
end

function Genesis.objects.get_region_key_for_pos(pos)
    local rx, rz = Genesis.objects.get_region_coords(pos)
    if not rx or not rz then
        return nil
    end

    return Genesis.objects.region_key(rx, rz)
end

function Genesis.objects.add_to_region(obj)
    if not obj.pos then
        return
    end

    local key = Genesis.objects.get_region_key_for_pos(obj.pos)
    if not key then
        return
    end

    Genesis.objects.regions[key] = Genesis.objects.regions[key] or {}
    Genesis.objects.regions[key][obj.id] = true
    obj.region_key = key
end

function Genesis.objects.remove_from_region(obj)
    if not obj.region_key then
        return
    end

    local region = Genesis.objects.regions[obj.region_key]
    if region then
        region[obj.id] = nil
    end

    obj.region_key = nil
end

function Genesis.objects.rebuild_spatial_index()
    Genesis.objects.regions = {}

    for _, obj in pairs(Genesis.objects.items) do
        if obj.lifecycle and obj.lifecycle.active and obj.pos then
            Genesis.objects.add_to_region(obj)
        end
    end

    Genesis.log("Spatial index rebuilt")
end

function Genesis.objects.create(def)
    local id = Genesis.objects.next_id
    Genesis.objects.next_id = Genesis.objects.next_id + 1

    local obj = {
        id = id,
        object_type = def.object_type or "generic",
        subtype = def.subtype or "unknown",
        name = def.name or ("Object " .. id),

        pos = def.pos or nil,
        region_key = nil,

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
    Genesis.objects.add_to_region(obj)

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

    Genesis.objects.remove_from_region(obj)

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

function Genesis.objects.move(id, new_pos)
    local obj = Genesis.objects.get(id)

    if not obj or not obj.lifecycle.active then
        return false
    end

    Genesis.objects.remove_from_region(obj)

    obj.pos = new_pos

    Genesis.objects.add_to_region(obj)

    Genesis.events.emit("object_moved", obj)

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

function Genesis.objects.find_by_region(rx, rz)
    local key = Genesis.objects.region_key(rx, rz)
    local region = Genesis.objects.regions[key]
    local results = {}

    if not region then
        return results
    end

    for id, _ in pairs(region) do
        local obj = Genesis.objects.get(id)
        if obj and obj.lifecycle.active then
            table.insert(results, obj)
        end
    end

    return results
end

function Genesis.objects.distance(a, b)
    local dx = a.x - b.x
    local dz = a.z - b.z
    local dy = (a.y or 0) - (b.y or 0)

    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function Genesis.objects.find_near(pos, radius, object_type)
    local results = {}

    local center_rx, center_rz = Genesis.objects.get_region_coords(pos)
    if not center_rx or not center_rz then
        return results
    end

    local region_radius = math.ceil(radius / Genesis.objects.region_size)

    for rx = center_rx - region_radius, center_rx + region_radius do
        for rz = center_rz - region_radius, center_rz + region_radius do
            local region_objects = Genesis.objects.find_by_region(rx, rz)

            for _, obj in ipairs(region_objects) do
                if (not object_type or obj.object_type == object_type)
                    and obj.pos
                    and Genesis.objects.distance(pos, obj.pos) <= radius then
                    table.insert(results, obj)
                end
            end
        end
    end

    return results
end

Genesis.events.on("simulation_started", function(saved_state)
    if saved_state and saved_state.objects then
        Genesis.objects.items = saved_state.objects.items or {}
        Genesis.objects.next_id = saved_state.objects.next_id or 1
        Genesis.objects.rebuild_spatial_index()
        Genesis.log("Objects restored from save")
    else
        Genesis.objects.rebuild_spatial_index()
    end
end)

Genesis.log("Genesis Objects v1.0 loaded")
