local modpath = minetest.get_modpath("genesis_core")

dofile(modpath .. "/world.lua")
dofile(modpath .. "/logger.lua")
dofile(modpath .. "/time.lua")
dofile(modpath .. "/api.lua")

Genesis.log("=========================")
Genesis.log("Genesis Core v" .. Genesis.world.version)
Genesis.log("World Loaded")
Genesis.log(Genesis.log_time())
Genesis.log("=========================")

Genesis.start_clock()
