Genesis = Genesis or {}
Genesis.life = Genesis.life or {}

function Genesis.life.default_data()
    return {
        body = {
            health = 100,
            max_health = 100,

            hunger = 0,
            thirst = 0,
            energy = 100,
            stamina = 100,
            sleep = 0,

            temperature = 98.6,
            temperature_min = 95,
            temperature_max = 104,

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
        },

        senses = {
            vision = 12,
            hearing = 10,
            smell = 4,
            touch = 5,
            taste = 5
        },

        mind = {
            intelligence = 10,
            curiosity = 50,
            fear = 0,
            aggression = 0,
            social = 50,
            mood = "neutral",
            stress = 0,
            trust = {},
            personality = {}
        },

        inventory = {},

        memory = {
            places = {},
            events = {},
            resources = {},
            dangers = {},
            beings = {}
        },

        knowledge = {},

        goals = {
            current = "survive",
            queue = {}
        },

        relationships = {},

        lifecycle = {
            alive = true,
            born = {
                year = Genesis.world.year,
                day = Genesis.world.day,
                tick = Genesis.world.tick
            },
            reproduction_ready = false,
            generation = 1
        }
    }
end

function Genesis.life.create(def)
    local obj = Genesis.objects.create({
        object_type = "life",
        subtype = def.species or "human_proto",
        name = def.name or "Unnamed Life",
        pos = def.pos or {x = 0, y = 1, z = 0},
        data = Genesis.life.default_data()
    })

    obj.data.life_type = def.type or "agent"
    obj.data.species = def.species or "human_proto"

    Genesis.log("Life created: " .. obj.name .. " [" .. obj.data.species .. "]")
    Genesis.events.emit("life_spawned", obj)

    return obj
end

function Genesis.life.update(obj)
    if not obj.lifecycle.active then
        return
    end

    local data = obj.data
    local body = data.body

    if not data.lifecycle.alive then
        return
    end

    body.hunger = body.hunger + 0.1
    body.thirst = body.thirst + 0.15
    body.energy = math.max(0, body.energy - 0.05)
    body.stamina = math.min(100, body.stamina + 0.1)

        -- Basic survival behavior: drink if thirsty and water exists in region
    if body.thirst >= 70 then
        local region = Genesis.regions.get_at_pos(obj.pos)

        if region.resources.water and region.resources.water > 0 then
            local drink_amount = math.min(10, region.resources.water)

            region.resources.water = region.resources.water - drink_amount
            region.modified = true

            body.thirst = math.max(0, body.thirst - 25)
            body.hydration = math.min(100, body.hydration + 25)

            obj.data.memory.resources["water:" .. region.key] = {
                region = region.key,
                discovered = {
                    year = Genesis.world.year,
                    day = Genesis.world.day,
                    tick = Genesis.world.tick
                },
                confidence = 1.0
            }

            Genesis.log(obj.name .. " drank water in region " .. region.key)
            Genesis.events.emit("life_drank_water", {
                life = obj,
                region = region,
                amount = drink_amount
            })
        else
            obj.data.goals.current = "find_water"
            Genesis.log(obj.name .. " is thirsty and needs water")
        end
    end

    if body.hunger >= 100 or body.thirst >= 100 then
        body.health = body.health - 0.5
    end

    if body.health <= 0 then
        body.health = 0
        data.lifecycle.alive = false
        Genesis.objects.destroy(obj.id, "death")
        Genesis.log(obj.name .. " has died")
        Genesis.events.emit("life_died", obj)
    end
end

function Genesis.life.tick()
    local living = Genesis.objects.find_by_type("life")
    for _, obj in ipairs(living) do
    local region = Genesis.regions.get_at_pos(obj.pos)
    Genesis.log(obj.name .. " is in region " .. region.key .. " biome=" .. region.biome)
end

    for _, obj in ipairs(living) do
        Genesis.life.update(obj)

        local body = obj.data.body

        Genesis.log(
            obj.name ..
            " | health=" .. string.format("%.1f", body.health) ..
            " hunger=" .. string.format("%.1f", body.hunger) ..
            " thirst=" .. string.format("%.1f", body.thirst) ..
            " energy=" .. string.format("%.1f", body.energy)
        )
    end
end

Genesis.events.on("simulation_started", function(saved_state)
    local living = Genesis.objects.find_by_type("life")

    if #living == 0 then
        Genesis.life.create({
            type = "agent",
            species = "human_proto",
            name = "Agent 1",
            pos = {x = 0, y = 1, z = 0}
        })
    else
        Genesis.log("Life restored from object registry: " .. #living .. " living objects")
    end
end)

Genesis.events.on("tick", function(world)
    if world.tick > 0 and world.tick % 5 == 0 then
        Genesis.life.tick()
    end
end)

Genesis.events.on("tick", function(world)
    if world.tick > 0 and world.tick % 60 == 0 then
        Genesis.storage.save()
    end
end)

Genesis.log("Genesis Life v0.2 loaded")
