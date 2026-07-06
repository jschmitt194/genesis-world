Genesis.ai.tasks = {}

function Genesis.ai.tasks.ensure(obj)
    obj.data.tasks = obj.data.tasks or {
        current = nil,
        queue = {}
    }

    return obj.data.tasks
end

function Genesis.ai.tasks.set(obj, task)
    local tasks = Genesis.ai.tasks.ensure(obj)
    tasks.current = task
    obj.data.goals.current = task.name

    Genesis.log(obj.name .. " task set: " .. task.name)
end

function Genesis.ai.tasks.clear(obj)
    local tasks = Genesis.ai.tasks.ensure(obj)
    tasks.current = nil
    obj.data.goals.current = nil
end

function Genesis.ai.tasks.get(obj)
    return Genesis.ai.tasks.ensure(obj).current
end
