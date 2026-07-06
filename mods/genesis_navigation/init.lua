Genesis = Genesis or {}
Genesis.navigation = Genesis.navigation or {}

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

function Genesis.navigation.step_toward(obj)
    if not Genesis.navigation.has_target(obj) then
        return false
    end

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

    Genesis.objects.move(obj.id, {
        x = nx,
        y = pos.y,
        z = nz
    })

    local body = Genesis.life.body.ensure(obj)
    body.energy = math.max(0, body.energy - 0.1)
    body.stamina = math.max(0, body.stamina - 0.2)

    Genesis.log(obj.name .. " walked to x=" .. string.format("%.1f", nx) .. " z=" .. string.format("%.1f", nz))

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

Genesis.log("Genesis Navigation v0.1 loaded")
