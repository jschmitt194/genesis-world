Genesis.ai.needs = {}

function Genesis.ai.needs.score(obj)
    Genesis.life.ensure_data(obj)

    local body = obj.data.body

    return {
        water = body.thirst or 0,
        food = body.hunger or 0,
        rest = math.max(0, 100 - (body.energy or 100)),
        health = math.max(0, 100 - (body.health or 100))
    }
end

function Genesis.ai.needs.top(obj)
    local scores = Genesis.ai.needs.score(obj)
    local best_name = nil
    local best_score = -1

    for name, score in pairs(scores) do
        if score > best_score then
            best_name = name
            best_score = score
        end
    end

    return best_name, best_score, scores
end
