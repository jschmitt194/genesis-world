Genesis = Genesis or {}
Genesis.worldsim = Genesis.worldsim or {}

function Genesis.worldsim.ensure_region_resources(region)
    region.resources = region.resources or {}

    region.resources.water = region.resources.water or 0
    region.resources.food = region.resources.food or 0
    region.resources.grass = region.resources.grass or 100
    region.resources.trees = region.resources.trees or 0
    region.resources.berries = region.resources.berries or 0
    region.resources.wood = region.resources.wood or 0
    region.resources.stone = region.resources.stone or 0

    region.danger = region.danger or {
        fire = 0,
        flood = 0,
        disease = 0
    }

    region.ecology = region.ecology or {
        score = 0,
        last_updated_tick = Genesis.world.tick
    }
end

function Genesis.worldsim.update_region(region)
    Genesis.worldsim.ensure_region_resources(region)

    local climate = region.climate or {}
    local resources = region.resources

    local rainfall = climate.rainfall or 50
    local temperature = climate.temperature or 72
    local humidity = climate.humidity or 50

    -- Water balance
    local rain_gain = rainfall * 0.02
    local evaporation = math.max(0, (temperature - 50) * 0.01)

    resources.water = math.max(0, resources.water + rain_gain - evaporation)

    -- Grass growth
    local grass_growth = (resources.water * 0.001) + (humidity * 0.01)
    resources.grass = math.min(1000, resources.grass + grass_growth)

    -- Food growth from grass and berries
    local food_growth = resources.grass * 0.002
    resources.food = math.min(500, resources.food + food_growth)

    -- Tree and berry growth
    local tree_growth = resources.grass * 0.0001
    resources.trees = math.min(300, resources.trees + tree_growth)

    local berry_growth = resources.trees * 0.01
    resources.berries = math.min(300, resources.berries + berry_growth)

    -- Wood availability from trees
    resources.wood = math.max(resources.wood, resources.trees * 5)

    -- Region score for future AI migration/settlement
    local danger_score = 0
    if region.danger then
        danger_score =
            (region.danger.fire or 0) +
            (region.danger.flood or 0) +
            (region.danger.disease or 0)
    end

    region.ecology.score =
        (resources.water * 1.5) +
        (resources.food * 1.2) +
        (resources.wood * 0.4) +
        (resources.stone * 0.2) -
        (danger_score * 2)

    region.ecology.last_updated_tick = Genesis.world.tick
    region.modified = true
end

function Genesis.worldsim.update_all_regions()
    local count = 0

    for _, region in pairs(Genesis.regions.items or {}) do
        Genesis.worldsim.update_region(region)
        count = count + 1
    end

    Genesis.log("World ecology updated for " .. count .. " regions")
end

Genesis.events.on("hour", function(world)
    Genesis.worldsim.update_all_regions()
end)

Genesis.log("Genesis World v0.1 loaded")
