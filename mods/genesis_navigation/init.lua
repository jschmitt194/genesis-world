Genesis = Genesis or {}
Genesis.navigation = Genesis.navigation or {}

Genesis.navigation.scan_min_y = -64
Genesis.navigation.scan_max_y = 128
Genesis.navigation.max_step_up = 1
Genesis.navigation.max_safe_drop = 2

function Genesis.navigation.set_target(obj, pos)
    obj.data.navigation = obj.data.navigation or {}

    obj.data.navigation.target = {
        x = pos.x,
        y = pos.y or obj.pos.y,
        z = pos.z
    }

    Genesis.log(obj.name .. " navigation target set to x=" .. pos.x .. " z=" .. pos.z)
end

function Genesis.navigation.has_target(obj)
    return obj.data
        and obj.data.navigation
        and obj.data.navigation.target ~= nil
end

function Genesis.navigation.clear_target(obj)
    if obj.data and obj.data.navigation then
        obj.data.navigation.target = nil
    end
end

function Genesis.navigation.is_walkable_node(name)
    if name == "air" or name == "ignore" then
        return false
    end

    if name:find("water") or name:find("lava") then
        return false
    end

    return true
end

function Genesis.navigation.ground_y_at(x, z)
    for y = Genesis.navigation.scan_max_y, Genesis.navigation.scan_min_y, -1 do
        local node = minetest.get_node({
            x = math.floor(x + 0.5),
            y = y,
            z = math.floor(z + 0.5)
        })

        if Genesis.navigation.is_walkable_node(node.name) then
            return y + 1, node.name
        end
    end

    return nil, nil
end

function Genesis.navigation.step_toward(obj)
    if not Genesis.navigation.has_target(obj) then
        return false
    end

    Genesis.life.ensure_data(obj)

    local target = obj.data.navigation.target
    local pos = obj.pos

    local dx = target.x - pos.x
    local dz = target.z - pos.z
    local dist = math.sqrt(dx * dx + dz * dz)

    if dist < 1 then
        Genesis.navigation.clear_target(obj)
        Genesis.log(obj.name .. " arrived at navigation target")
        return true
    end

    local step = 1
    local nx = pos.x + (dx / dist) * step
    local nz = pos.z + (dz / dist) * step

    local ny, ground_node = Genesis.navigation.ground_y_at(nx, nz)

    if not ny then
        ny = pos.y
        ground_node = "unknown"
        Genesis.log(obj.name .. " using current height because ground ahead is not loaded")
    end

    local height_delta = ny - pos.y

    if height_delta > Genesis.navigation.max_step_up then
        Genesis.log(obj.name .. " blocked by climb height " .. string.format("%.1f", height_delta))
        Genesis.navigation.clear_target(obj)
        return false
    end

    if height_delta < -Genesis.navigation.max_safe_drop then
        Genesis.log(obj.name .. " stopped at dangerous drop " .. string.format("%.1f", height_delta))
        Genesis.navigation.clear_target(obj)
        return false
    end

    Genesis.objects.move(obj.id, {
        x = nx,
        y = ny,
        z = nz
    })

    local body = Genesis.life.body.ensure(obj)

    local energy_cost = 0.1
    local stamina_cost = 0.2

    if height_delta > 0 then
        energy_cost = energy_cost + (height_delta * 0.1)
        stamina_cost = stamina_cost + (height_delta * 0.3)
    end

    if ground_node and ground_node:find("sand") then
        energy_cost = energy_cost + 0.1
        stamina_cost = stamina_cost + 0.1
    end

    body.energy = math.max(0, body.energy - energy_cost)
    body.stamina = math.max(0, body.stamina - stamina_cost)

    Genesis.log(
        obj.name ..
        " walked to x=" .. string.format("%.1f", nx) ..
        " y=" .. string.format("%.1f", ny) ..
        " z=" .. string.format("%.1f", nz) ..
        " on " .. tostring(ground_node)
    )

    return false
end

Genesis.events.on("tick", function(world)
    if world.tick > 0 and world.tick % 5 == 0 then
        local living = Genesis.objects.find_by_type("life")

        for _, obj in ipairs(living) do
            Genesis.life.ensure_data(obj)

            if Genesis.navigation.has_target(obj) then
                Genesis.navigation.step_toward(obj)
            end
        end
    end
end)

Genesis.log("Genesis Navigation v0.2 loaded")
