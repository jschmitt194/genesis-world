Genesis = Genesis or {}

local accumulator = 0

function Genesis.advance_time()
    local w = Genesis.world

    w.tick = w.tick + 1
    w.minute = w.minute + 1

    if w.minute >= 60 then
        w.minute = 0
        w.hour = w.hour + 1
    end

    if w.hour >= 24 then
        w.hour = 0
        w.day = w.day + 1
    end

    if w.day > 365 then
        w.day = 1
        w.year = w.year + 1
    end

    Genesis.log("Tick " .. w.tick .. " | " .. Genesis.log_time())
Genesis.events.emit("tick", w)

if w.minute == 0 then
    Genesis.events.emit("hour", w)
end

if w.hour == 0 and w.minute == 0 then
    Genesis.events.emit("day", w)
end
end

function Genesis.start_clock()
    Genesis.log("Clock started")

    minetest.register_globalstep(function(dtime)
        if not Genesis.world.running then
            return
        end

        accumulator = accumulator + dtime

        if accumulator >= 1 then
            accumulator = 0
            Genesis.advance_time()
        end
    end)
end
