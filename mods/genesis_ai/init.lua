Genesis = Genesis or {}
Genesis.ai = Genesis.ai or {}

local modpath = minetest.get_modpath("genesis_ai")

dofile(modpath .. "/needs.lua")
dofile(modpath .. "/tasks.lua")
dofile(modpath .. "/thoughts.lua")
dofile(modpath .. "/planner.lua")

Genesis.log("Genesis AI v0.2 loaded")
