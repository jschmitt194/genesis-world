local modpath = minetest.get_modpath("genesis_core")

dofile(modpath .. "/world.lua")
dofile(modpath .. "/logger.lua")
dofile(modpath .. "/events.lua")
dofile(modpath .. "/storage.lua")
dofile(modpath .. "/time.lua")
dofile(modpath .. "/api.lua")

local saved_state = Genesis.storage.load()

if saved_state and saved_state.world then
    Genesis.world = saved_state.world
end

Genesis.log("=========================")
Genesis.log("Genesis Core v" .. Genesis.world.version)
Genesis.log("World Loaded")
Genesis.log(Genesis.log_time())
Genesis.log("=========================")

minetest.after(0, function()
    Genesis.events.emit("simulation_started", saved_state)
    Genesis.start_clock()
end)

Genesis.start_clock()

minetest.register_on_shutdown(function()
    Genesis.storage.save()
end)
