Genesis = Genesis or {}

Genesis.storage = {}

local worldpath = minetest.get_worldpath()
local save_dir = worldpath .. "/genesis_data"
local save_file = save_dir .. "/world_state.json"

function Genesis.storage.ensure_dir()
    minetest.mkdir(save_dir)
end

function Genesis.storage.collect_state()
    return {
        world = Genesis.world,
        objects = {
            items = Genesis.objects and Genesis.objects.items or {},
            next_id = Genesis.objects and Genesis.objects.next_id or 1
        },
        life = Genesis.life and Genesis.life.objects or {}
    }
end

function Genesis.storage.save()
    Genesis.storage.ensure_dir()

    local state = Genesis.storage.collect_state()
    local json = minetest.write_json(state, true)

    local file = io.open(save_file, "w")
    if not file then
        Genesis.log("ERROR: Could not open save file")
        return false
    end

    file:write(json)
    file:close()

    Genesis.log("World state saved")
    return true
end

function Genesis.storage.load()
    local file = io.open(save_file, "r")
    if not file then
        Genesis.log("No Genesis save file found; starting fresh")
        return nil
    end

    local data = file:read("*all")
    file:close()

    local state = minetest.parse_json(data)
    if not state then
        Genesis.log("ERROR: Could not parse Genesis save file")
        return nil
    end

    Genesis.log("World state loaded")
    return state
end
