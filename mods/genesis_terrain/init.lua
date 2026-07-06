Genesis = Genesis or {}
Genesis.terrain = Genesis.terrain or {}

function Genesis.terrain.properties(node_name)
    local p = {
        name = node_name,
        solid = true,
        walkable = true,
        blocks_movement = true,
        blocks_vision = true,
        drinkable = false,
        swimmable = false,
        flammable = false,
        harvestable = false,
        resource = nil,
        terrain_cost = 1.0,
        dangerous = false
    }

    if node_name == "air" or node_name == "ignore" then
        p.solid = false
        p.walkable = false
        p.blocks_movement = false
        p.blocks_vision = false
        return p
    end

    if node_name:find("water") then
        p.solid = false
        p.walkable = false
        p.blocks_movement = true
        p.blocks_vision = false
        p.drinkable = true
        p.swimmable = true
        p.resource = "water"
        p.terrain_cost = 3.0
        return p
    end

    if node_name:find("lava") or node_name:find("fire") then
        p.dangerous = true
        p.blocks_vision = false
        p.resource = "heat"
        return p
    end

    if node_name:find("sand") then
        p.resource = "sand"
        p.terrain_cost = 1.5
        return p
    end

    if node_name:find("snow") or node_name:find("ice") then
        p.resource = "snow"
        p.terrain_cost = 1.7
        return p
    end

    if node_name:find("stone") then
        p.resource = "stone"
        p.harvestable = true
        p.terrain_cost = 1.2
        return p
    end

    if node_name:find("tree") or node_name:find("wood") then
        p.resource = "wood"
        p.harvestable = true
        p.flammable = true
        p.terrain_cost = 2.0
        return p
    end

    if node_name:find("leaves") then
        p.resource = "leaves"
        p.harvestable = true
        p.flammable = true
        p.blocks_vision = true
        p.terrain_cost = 2.0
        return p
    end

    if node_name:find("grass") or node_name:find("dirt") then
        p.resource = "soil"
        p.blocks_vision = false
        p.terrain_cost = 1.0
        return p
    end

    return p
end

function Genesis.terrain.node_at(pos)
    local node = minetest.get_node(pos)
    return node.name, Genesis.terrain.properties(node.name)
end

Genesis.log("Genesis Terrain v0.1 loaded")
