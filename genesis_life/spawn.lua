Genesis.life.spawn = {}

function Genesis.life.default_data()
    return {
        body = Genesis.life.body.default(),
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
        memory = Genesis.life.memory.default(),
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

function Genesis.life.ensure_data(obj)
    local defaults = Genesis.life.default_data()

    obj.data = obj.data or {}
    obj.data.body = obj.data.body or defaults.body
    obj.data.senses = obj.data.senses or defaults.senses
    obj.data.mind = obj.data.mind or defaults.mind
    obj.data.inventory = obj.data.inventory or {}
    obj.data.memory = obj.data.memory or defaults.memory
    obj.data.memory.resources = obj.data.memory.resources or {}
    obj.data.knowledge = obj.data.knowledge or {}
    obj.data.goals = obj.data.goals or defaults.goals
    obj.data.lifecycle = obj.data.lifecycle or defaults.lifecycle
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
