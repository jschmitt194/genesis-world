Genesis = Genesis or {}
Genesis.senses = Genesis.senses or {}

function Genesis.senses.vision_range(obj)
    Genesis.life.ensure_data(obj)

    local base = obj.data.senses.vision or Genesis.config.base_vision or 12
    return Genesis.physics.effective_vision(base, obj.pos)
end

function Genesis.senses.observe_regions(obj)
    local range = Genesis.senses.vision_range(obj)
    local region_radius = math.max(1, math.floor(range / Genesis.regions.size))
    local regions = Genesis.regions.find_near(obj.pos, region_radius)

    Genesis.life.memory.ensure(obj)

    for _, region in ipairs(regions) do
        obj.data.memory.places[region.key] = {
            region = region.key,
            biome = region.biome,
            resources = {
                water = region.resources.water or 0,
                food = region.resources.food or 0,
                wood = region.resources.wood or 0,
                stone = region.resources.stone or 0
            },
            seen = {
                year = Genesis.world.year,
                day = Genesis.world.day,
                tick = Genesis.world.tick
            },
            confidence = 1.0
        }
    end

    Genesis.log(obj.name .. " looked around and observed " .. #regions .. " regions")
end

Genesis.events.on("tick", function(world)
    if world.tick > 0 and world.tick % 10 == 0 then
        local living = Genesis.objects.find_by_type("life")

        for _, obj in ipairs(living) do
            Genesis.senses.observe_regions(obj)
        end
    end
end)

Genesis.log("Genesis Senses v0.1 loaded")
