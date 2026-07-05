minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_air = minetest.get_content_id("air")
    local c_dirt = minetest.get_content_id("default:dirt")
    local c_grass = minetest.get_content_id("default:dirt_with_grass")

    for z = minp.z, maxp.z do
        for y = minp.y, maxp.y do
            for x = minp.x, maxp.x do
                local vi = area:index(x, y, z)

                if y < -1 then
                    data[vi] = c_dirt
                elseif y == -1 then
                    data[vi] = c_grass
                else
                    data[vi] = c_air
                end
            end
        end
    end

    vm:set_data(data)
    vm:set_lighting({day = 15, night = 0})
    vm:calc_lighting()
    vm:update_liquids()
    vm:write_to_map()
end)

minetest.register_on_newplayer(function(player)
    player:set_pos({x = 0, y = 2, z = 0})
end)

minetest.register_on_joinplayer(function(player)
    player:set_pos({x = 0, y = 2, z = 0})
end)
