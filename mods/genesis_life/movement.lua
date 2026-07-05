Genesis.life.movement = {}

function Genesis.life.movement.move_to_region(obj, region)
    local target_pos = {
        x = region.rx * Genesis.regions.size,
        y = obj.pos.y,
        z = region.rz * Genesis.regions.size
    }

    Genesis.objects.move(obj.id, target_pos)
    Genesis.log(obj.name .. " moved to region " .. region.key)
end
