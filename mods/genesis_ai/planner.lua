Genesis.ai.planner = {}

function Genesis.ai.planner.find_resource_region(obj, resource)
    local nearby = Genesis.regions.find_near(obj.pos, 1)

    for _, region in ipairs(nearby) do
        if region.resources[resource] and region.resources[resource] > 0 then
            return region
        end
    end

    return nil
end

function Genesis.ai.planner.plan(obj)
    local current = Genesis.ai.tasks.get(obj)

    if current then
        return
    end

    if Genesis.navigation and Genesis.navigation.has_target(obj) then
        return
    end

    local need, score = Genesis.ai.needs.top(obj)

    if score < 70 then
        Genesis.ai.tasks.clear(obj)
        return
    end

    if need == "water" then
        Genesis.ai.tasks.set(obj, {
            name = "get_water",
            resource = "water",
            status = "new"
        })
        return
    end

    if need == "food" then
        Genesis.ai.tasks.set(obj, {
            name = "get_food",
            resource = "food",
            status = "new"
        })
        return
    end

    if need == "rest" then
        Genesis.ai.tasks.set(obj, {
            name = "rest",
            status = "new"
        })
        return
    end
end

function Genesis.ai.planner.execute(obj)
    local task = Genesis.ai.tasks.get(obj)

    if not task then
        Genesis.ai.planner.plan(obj)
        task = Genesis.ai.tasks.get(obj)
    end

    if not task then
        return
    end

    if Genesis.navigation and Genesis.navigation.has_target(obj) then
        return
    end

    local region = Genesis.regions.get_at_pos(obj.pos)

    if task.name == "get_water" then
        if Genesis.life.actions.drink(obj, region) then
            Genesis.ai.tasks.clear(obj)
            return
        end

        local target = Genesis.ai.planner.find_resource_region(obj, "water")
        if target then
            task.status = "walking"
            Genesis.life.movement.move_to_region(obj, target)
        else
            Genesis.log(obj.name .. " has task get_water but found no water nearby")
        end
        return
    end

    if task.name == "get_food" then
        if Genesis.life.actions.eat(obj, region) then
            Genesis.ai.tasks.clear(obj)
            return
        end

        local target = Genesis.ai.planner.find_resource_region(obj, "food")
        if target then
            task.status = "walking"
            Genesis.life.movement.move_to_region(obj, target)
        else
            Genesis.log(obj.name .. " has task get_food but found no food nearby")
        end
        return
    end

    if task.name == "rest" then
        local body = Genesis.life.body.ensure(obj)
        body.energy = math.min(100, body.energy + 5)
        Genesis.log(obj.name .. " rested")

        if body.energy >= 80 then
            Genesis.ai.tasks.clear(obj)
        end
    end
end

Genesis.events.on("tick", function(world)
    if world.tick > 0 and world.tick % 5 == 0 then
        local living = Genesis.objects.find_by_type("life")

        for _, obj in ipairs(living) do
            Genesis.ai.planner.plan(obj)
            Genesis.ai.planner.execute(obj)
        end
    end
end)
