Genesis.ai.thoughts = {}

function Genesis.ai.thoughts.ensure(obj)
    obj.data.thoughts = obj.data.thoughts or {}
    return obj.data.thoughts
end

function Genesis.ai.thoughts.add(obj, text)
    local thoughts = Genesis.ai.thoughts.ensure(obj)

    local thought = {
        text = text,
        time = {
            year = Genesis.world.year,
            day = Genesis.world.day,
            hour = Genesis.world.hour,
            minute = Genesis.world.minute,
            tick = Genesis.world.tick
        }
    }

    table.insert(thoughts, thought)

    if #thoughts > 20 then
        table.remove(thoughts, 1)
    end

    Genesis.log(obj.name .. " thinks: " .. text)
end
