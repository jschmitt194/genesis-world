Genesis = Genesis or {}
Genesis.brain = Genesis.brain or {}

function Genesis.brain.ensure(obj)
    obj.data = obj.data or {}
    obj.data.goals = obj.data.goals or {}
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

function Genesis.brain.clear_passive_goal(obj)
    if obj.data and obj.data.goals and obj.data.goals.current == "observe" then
        obj.data.goals.current = nil
    end
end

function Genesis.brain.evaluate(obj)
    Genesis.life.ensure_data(obj)
    Genesis.brain.ensure(obj)

    local body = Genesis.life.body.ensure(obj)

    -- Active navigation/task keeps running.
    if Genesis.navigation and Genesis.navigation.has_target(obj) then
        return
    end

    local current_task = Genesis.ai.tasks.get(obj)
    if current_task then
        Genesis.ai.planner.execute(obj)
        return
    end

    -- Observe is passive. Needs are allowed to override it.
    Genesis.brain.clear_passive_goal(obj)

    if body.thirst >= 60 then
        Genesis.brain.think(obj, "I am thirsty. I need water.")
        Genesis.ai.tasks.set(obj, {
            name = "get_water",
            resource = "water",
            status = "new"
        })
        Genesis.ai.planner.execute(obj)
        return
    end

    if body.hunger >= 60 then
        Genesis.brain.think(obj, "I am hungry. I need food.")
        Genesis.ai.tasks.set(obj, {
            name = "get_food",
            resource = "berries",
            status = "new"
        })
        Genesis.ai.planner.execute(obj)
        return
    end

    if body.energy <= 40 then
        Genesis.brain.think(obj, "I am tired. I need rest.")
        Genesis.ai.tasks.set(obj, {
            name = "rest",
            status = "new"
        })
        Genesis.ai.planner.execute(obj)
        return
    end

    Genesis.brain.think(obj, "My immediate needs are stable. I should observe my surroundings.")
    obj.data.goals.current = "observe"
end

Genesis.events.on("tick", function(world)
    if world.tick > 0 and world.tick % 5 == 0 then
        local living = Genesis.objects.find_by_type("life")

        for _, obj in ipairs(living) do
            Genesis.brain.evaluate(obj)
        end
    end
end)

Genesis.log("Genesis Brain v0.3 loaded")
