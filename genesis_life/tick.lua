Genesis.life.tick = {}

function Genesis.life.tick.update_life(obj)
    Genesis.life.ensure_data(obj)

    if not obj.lifecycle.active then return end
    if not obj.data.lifecycle.alive then return end

    local region = Genesis.regions.get_at_pos(obj.pos)
    Genesis.log(obj.name .. " is in region " .. region.key .. " biome=" .. region.biome)

    Genesis.life.body.metabolize(obj)
    Genesis.life.brain.think(obj)

    local body = Genesis.life.body.ensure(obj)

    Genesis.log(
        obj.name ..
        " | health=" .. string.format("%.1f", body.health) ..
        " hunger=" .. string.format("%.1f", body.hunger) ..
        " thirst=" .. string.format("%.1f", body.thirst) ..
        " energy=" .. string.format("%.1f", body.energy) ..
        " goal=" .. tostring(obj.data.goals.current)
    )
end

function Genesis.life.tick.all()
    local living = Genesis.objects.find_by_type("life")

    for _, obj in ipairs(living) do
        Genesis.life.tick.update_life(obj)
    end
end

Genesis.events.on("tick", function(world)
    if world.tick > 0 and world.tick % 5 == 0 then
        Genesis.life.tick.all()
    end
end)

Genesis.events.on("tick", function(world)
    if world.tick > 0 and world.tick % 60 == 0 then
        Genesis.storage.save()
    end
end)
