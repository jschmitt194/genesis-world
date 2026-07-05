Genesis = Genesis or {}
Genesis.regions = Genesis.regions or {}

Genesis.regions.items = Genesis.regions.items or {}
Genesis.regions.size = 16
Genesis.regions.scan_min_y = -32
Genesis.regions.scan_max_y = 128

function Genesis.regions.key(rx, rz)
    return tostring(rx) .. "," .. tostring(rz)
end

function Genesis.regions.coords_from_pos(pos)
    return math.floor(pos.x / Genesis.regions.size), math.floor(pos.z / Genesis.regions.size)
end

function Genesis.regions.classify_node(name)
    if name == "air" or name == "ignore" then return "air" end
    if name:find("water") then return "water" end
    if name:find("sand") then return "sand" end
    if name:find("snow") or name:find("ice") then return "snow" end
    if name:find("stone") then return "stone" end
    if name:find("tree") or name:find("wood") or name:find("leaves") then return "tree" end
    if name:find("grass") or name:find("dirt") then return "grass" end
    return "other"
end

function Genesis.regions.scan_region(rx, rz)
    local size = Genesis.regions.size
    local start_x = rx * size
    local start_z = rz * size

    local counts = {
        grass = 0,
        water = 0,
        stone = 0,
        sand = 0,
        snow = 0,
        tree = 0,
        other = 0
    }

    local elevation_sum = 0
    local elevation_min = nil
    local elevation_max = nil
    local samples = 0

    for x = start_x, start_x + size - 1 do
        for z = start_z, start_z + size - 1 do
            for y = Genesis.regions.scan_max_y, Genesis.regions.scan_min_y, -1 do
                local node = minetest.get_node({x = x, y = y, z = z})
                local class = Genesis.regions.classify_node(node.name)

                if class ~= "air" then
                    counts[class] = (counts[class] or 0) + 1

                    elevation_sum = elevation_sum + y
                    elevation_min = elevation_min and math.min(elevation_min, y) or y
                    elevation_max = elevation_max and math.max(elevation_max, y) or y
                    samples = samples + 1
                    break
                end
            end
        end
    end

    local avg = 0
    if samples > 0 then
        avg = elevation_sum / samples
    end

    local biome = "grassland"
    if counts.water > 128 then
        biome = "water"
    elseif counts.sand > 80 then
        biome = "desert"
    elseif counts.snow > 80 then
        biome = "snowfield"
    elseif counts.stone > 80 then
        biome = "rocky"
    elseif counts.tree > 40 then
        biome = "forest"
    end

    return {
        elevation = {
            average = avg,
            min = elevation_min or 0,
            max = elevation_max or 0
        },

        surface = counts,
        biome = biome
    }
end

function Genesis.regions.default_region(rx, rz)
    local key = Genesis.regions.key(rx, rz)
    local scan = Genesis.regions.scan_region(rx, rz)

    return {
        key = key,
        rx = rx,
        rz = rz,

        elevation = scan.elevation,
        surface = scan.surface,
        biome = scan.biome,

        climate = {
            temperature = 72,
            humidity = 50,
            rainfall = 50,
            wind = 0,
            light = 100
        },

        resources = {
            water = ((rx == 1 and rz == 0) and 100 or scan.surface.water * 10),
            wood = scan.surface.tree * 5,
            stone = scan.surface.stone * 5,
            food = 10,
            clay = 5,
            iron = 0
        },

        visibility = {
            tree_density = scan.surface.tree / (Genesis.regions.size * Genesis.regions.size),
            fog = 0,
            base_modifier = 1.0
        },

        heat = {
            ambient = 72
        },

        discovered = false,
        modified = false,
        scanned = true
    }
end

function Genesis.regions.get(rx, rz)
    local key = Genesis.regions.key(rx, rz)

    if not Genesis.regions.items[key] then
        Genesis.regions.items[key] = Genesis.regions.default_region(rx, rz)
        Genesis.log("Region created: " .. key)
        Genesis.log("Region " .. key .. " biome=" .. Genesis.regions.items[key].biome ..
            " avg_elevation=" .. string.format("%.1f", Genesis.regions.items[key].elevation.average))
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
    if not region.resources[resource] then return false end
    if region.resources[resource] < amount then return false end

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

Genesis.log("Genesis Regions v0.2 loaded")
