Genesis = Genesis or {}
Genesis.brain = Genesis.brain or {}

function Genesis.brain.ensure(obj)
    obj.data.brain = obj.data.brain or {
        current_thought = nil,
        attention = nil,
        last_decision_tick = 0,
        mood = "neutral"
    }

    return obj.data.brain
end

function Genesis.brain.think(obj, text)
    local brain = Genesis.brain.ensure(obj)
    brain.current_thought = text
    brain.last_decision_tick = Genesis.world.tick

    if Genesis.ai and Genesis.ai.thoughts then
        Genesis.ai.thoughts.add(obj, text)
    else
        Genesis.log(obj.name .. " thinks: " .. text)
    end
end

function Genesis.brain.evaluate(obj)
    Genesis.life.ensure_data(obj)

    local brain = Genesis.brain.ensure(obj)
    local body = obj.data.body

    if Genesis.navigation and Genesis.navigation.has_target(obj) then
        return
    end

    local current_task = Genesis.ai.tasks.get(obj)
    if current_task then
        return
    end

    local need, score = Genesis.ai.needs.top(obj)

    if score >= 70 then
        if need == "water" then
            Genesis.brain.think(obj, "I am thirsty. I need water.")
        elseif need == "food" then
            Genesis.brain.think(obj, "I am hungry. I need food.")
        elseif need == "rest" then
            Genesis.brain.think(obj, "I am tired. I need rest.")
        elseif need == "health" then
            Genesis.brain.think(obj, "I am injured. I need safety.")
        end

        Genesis.ai.planner.plan(obj)
        Genesis.ai.planner.execute(obj)
        return
    end

    if not obj.data.goals.current then
        Genesis.brain.think(obj, "My immediate needs are stable. I should observe my surroundings.")
        obj.data.goals.current = "observe"
    end
end

Genesis.events.on("tick", function(world)
    if world.tick > 0 and world.tick % 10 == 0 then
        local living = Genesis.objects.find_by_type("life")

        for _, obj in ipairs(living) do
            Genesis.brain.evaluate(obj)
        end
    end
end)

Genesis.log("Genesis Brain v0.1 loaded")
