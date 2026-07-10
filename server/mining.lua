local shared = require 'config.shared'

local mining = exports.lation_mining

------------------------------------------------------------
--  GET PLAYER LEVEL
------------------------------------------------------------
local function getLevel(src)
    return mining:GetPlayerData(src, 'level')
end

------------------------------------------------------------
--  ADD XP (FIXED)
------------------------------------------------------------
local function addXP(src, amount)
    mining:AddPlayerData(src, 'exp', amount)
end

------------------------------------------------------------
--  DURABILITY REDUCTION (OX INVENTORY)
------------------------------------------------------------
local function reduceDurability(src, itemName, amount)
    local metatype = shared.setup.durability or 'durability'
    exports.ox_inventory:Search(src, 'slots', itemName, function(slot)
        if slot.metadata and slot.metadata[metatype] then
            local new = slot.metadata[metatype] - amount
            if new < 0 then new = 0 end
            exports.ox_inventory:SetMetadata(src, slot.slot, metatype, new)
        end
    end)
end

------------------------------------------------------------
--  GIVE ORE REWARD
------------------------------------------------------------
local function giveReward(src, zoneId)
    local zone = shared.mining.zones[zoneId]
    if not zone then return end

    for _, reward in ipairs(zone.reward) do
        local qty = math.random(reward.min, reward.max)
        exports.ox_inventory:AddItem(src, reward.item, qty)
    end
end

------------------------------------------------------------
--  ORE MINED EVENT
------------------------------------------------------------
RegisterNetEvent('lation_mining:minedore', function(zoneId, oreId)
    local src = source
    local level = getLevel(src)
    local pickaxe = shared.pickaxes[level]
    if not pickaxe then return end

    -- Reduce durability
    reduceDurability(src, pickaxe.item, pickaxe.degrade)

    -- Give ore reward
    giveReward(src, zoneId)

    -- Add XP
    local zone = shared.mining.zones[zoneId]
    local xp = math.random(zone.xp.min, zone.xp.max)
    addXP(src, xp)
end)

------------------------------------------------------------
--  GET ITEM METADATA (OX)
------------------------------------------------------------
lib.callback.register('lation_mining:getmetadata', function(src, item)
    local items = exports.ox_inventory:Search(src, 'slots', item)
    if not items or not items[1] then return nil end
    return items[1].metadata
end)

------------------------------------------------------------
--  SMELTING CALLBACK
------------------------------------------------------------
lib.callback.register('lation_mining:smelt', function(src, ingotId)
    local ingot = shared.smelting.ingots[ingotId]
    if not ingot then return false end

    -- Check required items
    for _, req in ipairs(ingot.required) do
        if exports.ox_inventory:GetItem(src, req.item, false, true) < req.quantity then
            return false
        end
    end

    -- Remove required items
    for _, req in ipairs(ingot.required) do
        exports.ox_inventory:RemoveItem(src, req.item, req.quantity)
    end

    -- Add ingot
    for _, add in ipairs(ingot.add) do
        exports.ox_inventory:AddItem(src, add.item, add.quantity)
    end

    -- Add XP
    local xp = math.random(ingot.xp.min, ingot.xp.max)
    addXP(src, xp)

    return true
end)

------------------------------------------------------------
--  CRAFTING CALLBACK
------------------------------------------------------------
lib.callback.register('lation_mining:craft', function(src, recipe)
    if not recipe or not recipe.required then return false end

    -- Check required items
    for _, req in ipairs(recipe.required) do
        if exports.ox_inventory:GetItem(src, req.item, false, true) < req.quantity then
            return false
        end
    end

    -- Remove required items
    for _, req in ipairs(recipe.required) do
        exports.ox_inventory:RemoveItem(src, req.item, req.quantity)
    end

    -- Add crafted item
    exports.ox_inventory:AddItem(src, recipe.add.item, recipe.add.quantity, recipe.add.metadata or {})

    return true
end)
