-- Ensure proper seeding of math.random()
math.randomseed(os.time())

-- Initialize config(s)
local shared = require 'config.shared'

-- Initialize table to store player data
local cache = {}

-- Auto-inject SQL if needed
local sql = LoadResourceFile(GetCurrentResourceName(), 'install/lation_mining.sql')
if sql then MySQL.query(sql) end

------------------------------------------------------------
-- INSERT NEW PLAYER
------------------------------------------------------------
local function InsertPlayer(source)
    if not source then return end
    local identifier = GetIdentifier(source)
    if not identifier then return end

    local query = [[
        INSERT INTO `lation_mining`
        (identifier, name, level, exp, mined, smelted, earned)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ]]

    MySQL.insert(query, {identifier, GetName(source), 1, 0, 0, 0, 0})

    cache[identifier] = {
        identifier = identifier,
        name = GetName(source),
        level = 1,
        exp = 0,
        mined = 0,
        smelted = 0,
        earned = 0
    }

    return cache[identifier]
end

------------------------------------------------------------
-- GET PLAYER DATA
------------------------------------------------------------
local function GetPlayerData(source, type)
    if not source then return end
    local identifier = GetIdentifier(source)
    if not identifier then return end

    local data = cache[identifier]

    if not data then
        local query = [[ SELECT * FROM `lation_mining` WHERE `identifier` = ? ]]
        local result = MySQL.query.await(query, {identifier})

        if result and #result > 0 then
            data = result[1]
            cache[identifier] = data
        else
            data = InsertPlayer(source)
            if not data then return end
        end
    end

    if type then
        return data[type]
    end

    return data
end

------------------------------------------------------------
-- GET LEVEL TABLE
------------------------------------------------------------
local function getLevelData()
    return shared.experience
end

------------------------------------------------------------
-- ADD PLAYER DATA (FIXED)
------------------------------------------------------------
local function AddPlayerData(source, dataType, amount)
    amount = tonumber(amount)  -- FIX #1: force numeric XP

    if not source or not amount or not dataType or type(dataType) ~= 'string' then return end
    if amount <= 0 then return end

    local identifier = GetIdentifier(source)
    local data = identifier and GetPlayerData(source)
    if not identifier or not data then return end

    if dataType == 'exp' then
        local newExp = data.exp + amount

        -- FIX #2: correct level cap detection
        local maxLevel = 1
        for lvl, _ in pairs(shared.experience) do
            if lvl > maxLevel then maxLevel = lvl end
        end

        -- Level up loop
        while shared.experience[data.level + 1] and newExp >= shared.experience[data.level + 1] do
            data.level = data.level + 1
        end

        if data.level > maxLevel then
            data.level = maxLevel
        end

        cache[identifier].level = data.level
        cache[identifier].exp = newExp

    else
        cache[identifier][dataType] = (cache[identifier][dataType] or 0) + amount
    end
end

------------------------------------------------------------
-- SAVE PLAYER DATA
------------------------------------------------------------
local function SavePlayerData(identifier)
    if not identifier then return end
    local data = cache[identifier]
    if not data then return end

    local query = [[
        UPDATE `lation_mining`
        SET `level` = ?, `exp` = ?, `mined` = ?, `smelted` = ?, `earned` = ?
        WHERE `identifier` = ?
    ]]

    MySQL.update(query, {
        data.level,
        data.exp,
        data.mined,
        data.smelted,
        data.earned,
        identifier
    })

    cache[identifier] = nil
end

------------------------------------------------------------
-- GET TOP PLAYERS
------------------------------------------------------------
local function GetTopPlayers()
    local query = [[
        SELECT name, level, exp, mined
        FROM `lation_mining`
        ORDER BY exp DESC
        LIMIT 10
    ]]

    local result = MySQL.query.await(query)
    local players = {}

    if result and #result > 0 then
        for _, player in ipairs(result) do
            players[#players + 1] = {
                name = player.name or 'Unknown',
                level = player.level or 1,
                exp = player.exp or 0,
                mined = player.mined or 0
            }
        end
    end

    return players
end

------------------------------------------------------------
-- CALLBACKS
------------------------------------------------------------
lib.callback.register('lation_mining:gettopplayers', function()
    return GetTopPlayers()
end)

lib.callback.register('lation_mining:getplayerdata', function(source, type)
    return GetPlayerData(source, type)
end)

------------------------------------------------------------
-- SAVE ON RESOURCE STOP
------------------------------------------------------------
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for identifier, _ in pairs(cache) do
        SavePlayerData(identifier)
    end
end)

------------------------------------------------------------
-- SAVE ON SERVER SHUTDOWN
------------------------------------------------------------
AddEventHandler('txAdmin:events:serverShuttingDown', function()
    for identifier, _ in pairs(cache) do
        SavePlayerData(identifier)
    end
end)

------------------------------------------------------------
-- SAVE ON PLAYER DROP
------------------------------------------------------------
AddEventHandler('playerDropped', function()
    if not source then return end
    local identifier = GetIdentifier(source)
    if not identifier then return end
    SavePlayerData(identifier)
end)

------------------------------------------------------------
-- EXPORTS
------------------------------------------------------------
exports('GetPlayerData', GetPlayerData)
exports('AddPlayerData', AddPlayerData)
exports('GetLevelData', getLevelData)
exports('getLevelData', getLevelData)
