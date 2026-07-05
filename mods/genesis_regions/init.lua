Genesis = Genesis or {}
Genesis.regions = Genesis.regions or {}

Genesis.regions.items = Genesis.regions.items or {}
Genesis.regions.size = 16

function Genesis.regions.key(rx, rz)
    return tostring(rx) .. "," .. tostring(rz)
end

function Genesis.regions.coords_from_pos(pos)
    return math.floor(pos.x / Genesis.regions.size), math.floor(pos.z / Genesis.regions.size)
end

function Genesis.regions.default_region(rx, rz)
    local key = Genesis.regions.key(rx, rz)

    return {
        key = key,
        rx = rx,
        rz = rz,

        elevation = {
            average = 0,
            min = 0,
            max = 0
        },

        biome = "grassland",

        climate = {
            temperature = 72,
            humidity = 50,
            rainfall = 50,
            wind = 0,
            light = 100
        },

        resources = {
            water = 100,
            wood = 25,
            stone = 50,
            food = 10,
            clay = 5,
            iron = 0
        },

        visibility = {
            tree_density = 0.1,
            fog = 0,
            base_modifier = 1.0
        },

        heat = {
            ambient = 72
        },

        discovered = false,
        modified = false
    }
end

function Genesis.regions.get(rx, rz)
    local key = Genesis.regions.key(rx, rz)

    if not Genesis.regions.items[key] then
        Genesis.regions.items[key] = Genesis.regions.default_region(rx, rz)
        Genesis.log("Region created: " .. key)
        Genesis.events.emit("region_created", Genesis.regions.items[key])
    end

    return Genesis.regions.items[key]
end

function Genesis.regions.get_at_pos(pos)
    local rx, rz = Genesis.regions.coords_from_pos(pos)
    return Genesis.regions.get(rx, rz)
end

function Genesis.regions.find_near(pos, radius_regions)
    local rx, rz = Genesis.regions.coords_from_pos(pos)
    local results = {}

    for x = rx - radius_regions, rx + radius_regions do
        for z = rz - radius_regions, rz + radius_regions do
            table.insert(results, Genesis.regions.get(x, z))
        end
    end

    return results
end

function Genesis.regions.consume_resource(region, resource, amount)
    if not region.resources[resource] then
        return false
    end

    if region.resources[resource] < amount then
        return false
    end

    region.resources[resource] = region.resources[resource] - amount
    region.modified = true

    Genesis.events.emit("region_resource_changed", {
        region = region,
        resource = resource,
        amount = region.resources[resource]
    })

    return true
end

Genesis.events.on("simulation_started", function(saved_state)
    if saved_state and saved_state.regions then
        Genesis.regions.items = saved_state.regions.items or {}
        Genesis.log("Regions restored from save")
    else
        Genesis.log("No saved regions found; regions will be created lazily")
    end
end)

Genesis.log("Genesis Regions v0.1 loaded")
