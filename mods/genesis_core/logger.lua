Genesis = Genesis or {}

function Genesis.log(message)
    minetest.log("action", "[Genesis] " .. message)
end

function Genesis.log_time()
    local w = Genesis.world
    return string.format(
        "Year %d Day %d %02d:%02d",
        w.year,
        w.day,
        w.hour,
        w.minute
    )
end
