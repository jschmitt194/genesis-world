Genesis = Genesis or {}
Genesis.life = Genesis.life or {}
Genesis.life.objects = Genesis.life.objects or {}

local next_id = 1

function Genesis.life.create_life_object(def)
    local id = next_id
    next_id = next_id + 1

    local obj = {
        id = id,
        type = def.type or "agent",
        species = def.species or "human_proto",
        name = def.name or ("Life " .. id),

        pos = def.pos or {x = 0, y = 1, z = 0},

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
            born = {year = Genesis.world.year, day = Genesis.world.day},
            reproduction_ready = false,
            generation = 1
        }
    }

    Genesis.life.objects[id] = obj
    Genesis.log("Life object created: " .. obj.name .. " [" .. obj.species .. "]")
    return obj
end

function Genesis.life.update_life_object(obj)
    if not obj.lifecycle.alive then
        return
    end

    obj.body.hunger = obj.body.hunger + 0.1
    obj.body.thirst = obj.body.thirst + 0.15
    obj.body.energy = obj.body.energy - 0.05
    obj.body.stamina = math.min(100, obj.body.stamina + 0.1)

    if obj.body.hunger >= 100 or obj.body.thirst >= 100 then
        obj.body.health = obj.body.health - 0.5
    end

    if obj.body.health <= 0 then
        obj.body.health = 0
        obj.lifecycle.alive = false
        Genesis.log(obj.name .. " has died")
    end
end

function Genesis.life.tick()
    for _, obj in pairs(Genesis.life.objects) do
        Genesis.life.update_life_object(obj)

        Genesis.log(
            obj.name ..
            " | health=" .. string.format("%.1f", obj.body.health) ..
            " hunger=" .. string.format("%.1f", obj.body.hunger) ..
            " thirst=" .. string.format("%.1f", obj.body.thirst) ..
            " energy=" .. string.format("%.1f", obj.body.energy)
        )
    end
end

Genesis.events.on("simulation_started", function(saved_state)
    if saved_state and saved_state.life then
        Genesis.life.objects = saved_state.life
        Genesis.log("Life objects restored from save")
    else
        Genesis.life.create_life_object({
            type = "agent",
            species = "human_proto",
            name = "Agent 1",
            pos = {x = 0, y = 1, z = 0}
        })
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

Genesis.log("Genesis Life v0.1 loaded")
