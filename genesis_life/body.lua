Genesis.life.body = {}

function Genesis.life.body.default()
    return {
        health = 100,
        max_health = 100,
        hunger = 0,
        thirst = 0,
        energy = 100,
        stamina = 100,
        sleep = 0,
        temperature = 98.6,
        oxygen = 100,
        hydration = 100,
        nutrition = 100,
        strength = 10,
        speed = 10,
        endurance = 10,
        dexterity = 10,
        injury = {},
        disease = {},
        age = 0,
        lifespan = 80
    }
end

function Genesis.life.body.ensure(obj)
    obj.data = obj.data or {}
    obj.data.body = obj.data.body or Genesis.life.body.default()
    return obj.data.body
end

function Genesis.life.body.metabolize(obj)
    local body = Genesis.life.body.ensure(obj)

    body.hunger = body.hunger + 0.1
    body.thirst = body.thirst + 0.15
    body.energy = math.max(0, body.energy - 0.05)
    body.stamina = math.min(100, body.stamina + 0.1)

    if body.hunger >= 100 then
        body.health = math.max(0, body.health - 0.2)
    end

    if body.thirst >= 100 then
        body.health = math.max(0, body.health - 0.4)
    end

    if body.health <= 0 then
        body.health = 0
        obj.data.lifecycle.alive = false
        Genesis.objects.destroy(obj.id, "death")
        Genesis.log(obj.name .. " has died")
        Genesis.events.emit("life_died", obj)
    end
end
