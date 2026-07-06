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
    return math.floor(pos.x / Genesis.regions.size),
           math.floor(pos.z / Genesis.regions.size)
end

function Genesis.regions.classify_node(name)

    if name == "air" or name == "ignore" then
        return "air"
    end

    if name:find("water") then
        return "water"
    elseif name:find("sand") then
        return "sand"
    elseif name:find("snow") or name:find("ice") then
        return "snow"
    elseif name:find("stone") then
        return "stone"
    elseif name:find("tree") or
           name:find("wood") or
           name:find("leaves") then
        return "tree"
    elseif name:find("grass") or
           name:find("dirt") then
        return "grass"
    end

    return "other"

end

function Genesis.regions.scan_region(rx, rz)

    local size = Genesis.regions.size
    local sx = rx * size
    local sz = rz * size

    local counts = {
        grass = 0,
        water = 0,
        stone = 0,
        sand = 0,
        snow = 0,
        tree = 0,
        other = 0
    }

    local elev_sum = 0
    local elev_min = nil
    local elev_max = nil
    local samples = 0

    for x = sx, sx + size - 1 do
        for z = sz, sz + size - 1 do

            for y = Genesis.regions.scan_max_y,
                     Genesis.regions.scan_min_y,
                     -1 do

                local node = minetest.get_node({
                    x=x,
                    y=y,
                    z=z
                })

                local class =
                    Genesis.regions.classify_node(node.name)

                if class ~= "air" then

                    counts[class] =
                        (counts[class] or 0) + 1

                    elev_sum = elev_sum + y

                    elev_min =
                        elev_min and
                        math.min(elev_min,y) or y

                    elev_max =
                        elev_max and
                        math.max(elev_max,y) or y

                    samples = samples + 1
                    break

                end
            end
        end
    end

    local avg = 0

    if samples > 0 then
        avg = elev_sum / samples
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
            min = elev_min or 0,
            max = elev_max or 0
        },

        surface = counts,
        biome = biome

    }

end

function Genesis.regions.default_region(rx,rz)

    local scan = Genesis.regions.scan_region(rx,rz)

    return {

        key = Genesis.regions.key(rx,rz),

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
            water = ((rx==1 and rz==0) and 100 or scan.surface.water*10),
            wood = scan.surface.tree*5,
            stone = scan.surface.stone*5,
            food = 10,
            clay = 5,
            iron = 0
        },

        visibility = {
            tree_density =
                scan.surface.tree /
                (Genesis.regions.size*Genesis.regions.size),
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

function Genesis.regions.get(rx,rz)

    local key = Genesis.regions.key(rx,rz)

    if not Genesis.regions.items[key] then

        local region =
            Genesis.regions.default_region(rx,rz)

        Genesis.regions.items[key] = region

        Genesis.log("Region created: "..key)

        Genesis.log(
            "Region "..key..
            " biome="..region.biome..
            " avg_elevation="..
            string.format("%.1f",
                region.elevation.average)
        )

        Genesis.events.emit("region_created",region)

    end

    return Genesis.regions.items[key]

end

function Genesis.regions.get_at_pos(pos)

    local rx,rz =
        Genesis.regions.coords_from_pos(pos)

    return Genesis.regions.get(rx,rz)

end

function Genesis.regions.find_near(pos,radius)

    local rx,rz =
        Genesis.regions.coords_from_pos(pos)

    local results = {}

    for x = rx-radius, rx+radius do
        for z = rz-radius, rz+radius do
            table.insert(
                results,
                Genesis.regions.get(x,z)
            )
        end
    end

    return results

end

function Genesis.regions.consume_resource(region,name,amount)

    if not region.resources[name] then
        return false
    end

    if region.resources[name] < amount then
        return false
    end

    region.resources[name] =
        region.resources[name] - amount

    region.modified = true

    Genesis.events.emit(
        "region_resource_changed",
        {
            region = region,
            resource = name,
            amount = region.resources[name]
        }
    )

    return true

end

Genesis.events.on("simulation_started",function(saved)

    if saved and saved.regions then

        Genesis.regions.items =
            saved.regions.items or {}

        Genesis.log("Regions restored from save")

    else

        Genesis.log(
            "No saved regions found; regions will be created lazily"
        )

    end

end)

Genesis.log("Genesis Regions v0.3 loaded")
