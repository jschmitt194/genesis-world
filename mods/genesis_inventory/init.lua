Genesis = Genesis or {}
Genesis.inventory = Genesis.inventory or {}

function Genesis.inventory.ensure(obj)
    obj.data = obj.data or {}
    obj.data.inventory = obj.data.inventory or {}
end

function Genesis.inventory.add(obj, item, amount)

    Genesis.inventory.ensure(obj)

    amount = amount or 1

    obj.data.inventory[item] =
        (obj.data.inventory[item] or 0) + amount

    Genesis.log(
        obj.name ..
        " received " ..
        amount ..
        " " ..
        item
    )
end

function Genesis.inventory.remove(obj, item, amount)

    Genesis.inventory.ensure(obj)

    amount = amount or 1

    local current = obj.data.inventory[item] or 0

    if current < amount then
        return false
    end

    obj.data.inventory[item] = current - amount

    return true
end

function Genesis.inventory.count(obj, item)

    Genesis.inventory.ensure(obj)

    return obj.data.inventory[item] or 0

end

function Genesis.inventory.dump(obj)

    Genesis.inventory.ensure(obj)

    Genesis.log("Inventory for "..obj.name)

    for item,count in pairs(obj.data.inventory) do
        Genesis.log("  "..item.." = "..count)
    end

end

Genesis.log("Genesis Inventory v0.1 loaded")
