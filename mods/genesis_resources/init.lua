Genesis = Genesis or {}
Genesis.resources = Genesis.resources or {}

local defaults = {
    grass   = {min=20,max=80},
    berries = {min=0,max=25},
    sticks  = {min=0,max=20},
    trees   = {min=0,max=40},
    stone   = {min=5,max=50},
    water   = {min=0,max=50},
    food    = {min=0,max=30}
}

local function random_amount(def)
    return math.random(def.min, def.max)
end

function Genesis.resources.populate(region)

    if not region then
        return
    end

    region.resources = region.resources or {}

    if region.generated then
        return
    end

    for name, def in pairs(defaults) do
        region.resources[name] = random_amount(def)
    end

    region.generated = true

    Genesis.log("Resources generated for " .. region.key)

end

Genesis.events.on("simulation_started", function()

    if not Genesis.regions.items then
        return
    end

    for _, region in pairs(Genesis.regions.items) do
        Genesis.resources.populate(region)
    end

end)

Genesis.events.on("region_created", function(region)

    Genesis.resources.populate(region)

end)

Genesis.log("Genesis Resources v0.2 loaded")
