Genesis = Genesis or {}
Genesis.life = Genesis.life or {}

local modpath = minetest.get_modpath("genesis_life")

dofile(modpath .. "/body.lua")
dofile(modpath .. "/memory.lua")
dofile(modpath .. "/movement.lua")
dofile(modpath .. "/actions.lua")
dofile(modpath .. "/brain.lua")
dofile(modpath .. "/spawn.lua")
dofile(modpath .. "/tick.lua")

Genesis.log("Genesis Life v1.0 loaded")
