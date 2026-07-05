Genesis = Genesis or {}

function Genesis.get_world_state()
    return Genesis.world
end

function Genesis.pause()
    Genesis.world.running = false
    Genesis.log("Simulation paused")
end

function Genesis.resume()
    Genesis.world.running = true
    Genesis.log("Simulation resumed")
end
