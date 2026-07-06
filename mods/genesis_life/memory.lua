Genesis.life.memory = {}

function Genesis.life.memory.default()
    return {
        places = {},
        events = {},
        resources = {},
        dangers = {},
        beings = {}
    }
end

function Genesis.life.memory.ensure(obj)
    obj.data = obj.data or {}
    obj.data.memory = obj.data.memory or Genesis.life.memory.default()

    obj.data.memory.places = obj.data.memory.places or {}
    obj.data.memory.events = obj.data.memory.events or {}
    obj.data.memory.resources = obj.data.memory.resources or {}
    obj.data.memory.dangers = obj.data.memory.dangers or {}
    obj.data.memory.beings = obj.data.memory.beings or {}

    return obj.data.memory
end

function Genesis.life.memory.remember_resource(obj, resource, region)
    local memory = Genesis.life.memory.ensure(obj)

    memory.resources[resource .. ":" .. region.key] = {
        resource = resource,
        region = region.key,
        discovered = {
            year = Genesis.world.year,
            day = Genesis.world.day,
            tick = Genesis.world.tick
        },
        confidence = 1.0
    }
end
