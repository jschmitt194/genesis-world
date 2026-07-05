Genesis = Genesis or {}
Genesis.physics = Genesis.physics or {}

function Genesis.physics.distance(a, b)
    local dx = (a.x or 0) - (b.x or 0)
    local dy = (a.y or 0) - (b.y or 0)
    local dz = (a.z or 0) - (b.z or 0)

    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function Genesis.physics.elevation_above_sea(pos)
    local sea_level = Genesis.config.sea_level or 0
    return math.max(0, (pos.y or 0) - sea_level)
end

function Genesis.physics.elevation_vision_bonus(pos)
    local elevation = Genesis.physics.elevation_above_sea(pos)

    local step = Genesis.config.elevation_vision_step or 10
    local bonus_per_step = Genesis.config.elevation_vision_bonus or 1
    local max_bonus = Genesis.config.max_elevation_vision_bonus or 50

    local bonus = math.floor(elevation / step) * bonus_per_step

    return math.min(max_bonus, bonus)
end

function Genesis.physics.effective_vision(base_vision, pos)
    return base_vision + Genesis.physics.elevation_vision_bonus(pos)
end

function Genesis.physics.fire_heat_at_distance(distance)
    local damage_radius = Genesis.config.fire_damage_radius or 0.5
    local safe_radius = Genesis.config.fire_safe_warm_radius or 1.0
    local heat_radius = Genesis.config.fire_heat_radius or 3.0

    if distance < damage_radius then
        return {
            heat = 100,
            damage = 2.0,
            safe = false
        }
    end

    if distance <= safe_radius then
        return {
            heat = 75,
            damage = 0,
            safe = true
        }
    end

    if distance <= heat_radius then
        local falloff = 1 - ((distance - safe_radius) / (heat_radius - safe_radius))
        local heat = 75 * falloff

        return {
            heat = heat,
            damage = 0,
            safe = true
        }
    end

    return {
        heat = 0,
        damage = 0,
        safe = true
    }
end

Genesis.log("Genesis Physics v0.1 loaded")
