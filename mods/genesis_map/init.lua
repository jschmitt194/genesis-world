local MAP_SIZE = 512
local HALF = MAP_SIZE / 2

local c_air = minetest.get_content_id("air")
local c_grass = minetest.get_content_id("default:dirt_with_grass")
local c_dirt = minetest.get_content_id("default:dirt")
local c_sand = minetest.get_content_id("default:sand")
local c_water = minetest.get_content_id("default:water_source")
local c_snow = minetest.get_content_id("default:snowblock")
local c_stone = minetest.get_content_id("default:stone")

local function inside_map(x, z)
    return x >= -HALF and x <= HALF and z >= -HALF and z <= HALF
end

local function terrain_for(x, z)
    if not inside_map(x, z) then
        return c_water
    end

    -- north/south poles
    if z > 210 or z < -210 then
        return c_snow
    end

    -- diagonal equator desert band
    local equator = x
    if math.abs(z - equator) < 35 then
        return c_sand
    end

    -- mountain spine
    if x > 80 and x < 130 and z > -180 and z < 120 then
        return c_stone
    end

    -- oceans / edge water
    if x < -230 or x > 230 or z < -230 or z > 230 then
        return c_water
    end

    return c_grass
end

minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    for z = minp.z, maxp.z do
        for y = minp.y, maxp.y do
            for x = minp.x, maxp.x do
                local vi = area:index(x, y, z)

                if y < -4 then
                    data[vi] = c_stone
                elseif y < 0 then
                    data[vi] = c_dirt
                elseif y == 0 then
                    data[vi] = terrain_for(x, z)
                else
                    data[vi] = c_air
                end
            end
        end
    end

    vm:set_data(data)
    vm:set_lighting({day = 15, night = 0})
    vm:calc_lighting()
    vm:write_to_map()
end)

minetest.register_on_newplayer(function(player)
    player:set_pos({x = 0, y = 3, z = 0})
end)

minetest.register_on_joinplayer(function(player)
    player:set_pos({x = 0, y = 3, z = 0})
end)
