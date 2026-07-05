Genesis.life.brain = {}

function Genesis.life.brain.find_nearby_region_with_resource(obj, resource)
    local nearby = Genesis.regions.find_near(obj.pos, 1)

    for _, region in ipairs(nearby) do
        if region.resources[resource] and region.resources[resource] > 0 then
            return region
        end
    end

    return nil
end

function Genesis.life.brain.handle_thirst(obj)
    local body = Genesis.life.body.ensure(obj)

    if body.thirst < 70 then
        return
    end

    local region = Genesis.regions.get_at_pos(obj.pos)

    if Genesis.life.actions.drink(obj, region) then
        return
    end

    obj.data.goals.current = "find_water"
    Genesis.log(obj.name .. " is thirsty and needs water")

    local target = Genesis.life.brain.find_nearby_region_with_resource(obj, "water")

    if target then
        Genesis.life.movement.move_to_region(obj, target)
    else
        Genesis.log(obj.name .. " found no nearby water")
    end
end

function Genesis.life.brain.handle_hunger(obj)
    local body = Genesis.life.body.ensure(obj)

    if body.hunger < 70 then
        return
    end

    local region = Genesis.regions.get_at_pos(obj.pos)

    if Genesis.life.actions.eat(obj, region) then
        return
    end

    obj.data.goals.current = "find_food"
    Genesis.log(obj.name .. " is hungry and needs food")

    local target = Genesis.life.brain.find_nearby_region_with_resource(obj, "food")

    if target then
        Genesis.life.movement.move_to_region(obj, target)
    else
        Genesis.log(obj.name .. " found no nearby food")
    end
end

function Genesis.life.brain.think(obj)
    Genesis.life.brain.handle_thirst(obj)
    Genesis.life.brain.handle_hunger(obj)
end
