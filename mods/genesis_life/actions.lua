Genesis.life.actions = Genesis.life.actions or {}

function Genesis.life.actions.drink(obj, region)
    Genesis.life.ensure_data(obj)

    if not region or not region.resources then
        return false
    end

    local water = region.resources.water or 0
    if water <= 0 then
        return false
    end

    local drink_amount = math.min(10, water)

    region.resources.water = water - drink_amount
    region.modified = true

    local body = Genesis.life.body.ensure(obj)

    body.thirst = math.max(0, body.thirst - 25)
    body.hydration = math.min(100, (body.hydration or 100) + 25)

    Genesis.life.memory.remember_resource(obj, "water", region)

    Genesis.log(obj.name .. " drank water in region " .. region.key)

    return true
end

function Genesis.life.actions.eat(obj, region)
    Genesis.life.ensure_data(obj)

    local body = Genesis.life.body.ensure(obj)

    if Genesis.inventory and Genesis.inventory.count(obj, "berries") > 0 then
        Genesis.inventory.remove(obj, "berries", 1)

        body.hunger = math.max(0, body.hunger - 20)
        body.nutrition = math.min(100, (body.nutrition or 100) + 20)

        Genesis.log(obj.name .. " ate berries from inventory")
        Genesis.inventory.dump(obj)

        return true
    end

    return false
end

function Genesis.life.actions.harvest(obj, region, resource, amount)
    Genesis.life.ensure_data(obj)

    if not Genesis.inventory then
        Genesis.log("Inventory system not available")
        return false
    end

    if not region or not region.resources then
        return false
    end

    amount = amount or 1

    local available = region.resources[resource] or 0
    if available <= 0 then
        return false
    end

    local harvested = math.min(amount, available)

    region.resources[resource] = available - harvested
    region.modified = true

    Genesis.inventory.add(obj, resource, harvested)
    Genesis.life.memory.remember_resource(obj, resource, region)

    Genesis.log(obj.name .. " harvested " .. harvested .. " " .. resource .. " in region " .. region.key)

    Genesis.inventory.dump(obj)

    return true
end
