Genesis.life.actions = {}

function Genesis.life.actions.drink(obj, region)
    local body = Genesis.life.body.ensure(obj)

    if not region.resources.water or region.resources.water <= 0 then
        return false
    end

    local amount = math.min(10, region.resources.water)
    region.resources.water = region.resources.water - amount
    region.modified = true

    body.thirst = math.max(0, body.thirst - 25)
    body.hydration = math.min(100, (body.hydration or 100) + 25)

    Genesis.life.memory.remember_resource(obj, "water", region)

    obj.data.goals.current = nil

    Genesis.log(obj.name .. " drank water in region " .. region.key)
    Genesis.events.emit("life_drank_water", {
        life = obj,
        region = region,
        amount = amount
    })

    return true
end

function Genesis.life.actions.eat(obj, region)
    local body = Genesis.life.body.ensure(obj)

    if not region.resources.food or region.resources.food <= 0 then
        return false
    end

    local amount = math.min(5, region.resources.food)
    region.resources.food = region.resources.food - amount
    region.modified = true

    body.hunger = math.max(0, body.hunger - 20)
    body.nutrition = math.min(100, (body.nutrition or 100) + 20)

    Genesis.life.memory.remember_resource(obj, "food", region)

    obj.data.goals.current = nil

    Genesis.log(obj.name .. " ate food in region " .. region.key)
    Genesis.events.emit("life_ate_food", {
        life = obj,
        region = region,
        amount = amount
    })

    return true
end
