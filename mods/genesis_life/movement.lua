Genesis.life.movement = {}

function Genesis.life.movement.move_to_region(obj, region)
    local target_pos = {
        x = region.rx * Genesis.regions.size,
        y = obj.pos.y,
        z = region.rz * Genesis.regions.size
    }

    if Genesis.navigation then
        Genesis.navigation.set_target(obj, target_pos)
        Genesis.log(obj.name .. " started walking to region " .. region.key)
    else
        Genesis.objects.move(obj.id, target_pos)
        Genesis.log(obj.name .. " moved to region " .. region.key)
    end
end
