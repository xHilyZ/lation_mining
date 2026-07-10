-- Initialize config(s)
local shared = require 'config.shared'
local client = require 'config.client'
local icons  = require 'config.icons'

-- Initialize table to store ores
local ores = {}

-- Initialize variable to store inside mine state
local inside = false

-- Macro mining state
local isMacroMining = false 
local currentMacroZone = nil
local currentMacroOre = nil
local macroPosition = nil

-- Localize export
local mining = exports.lation_mining

------------------------------------------------------------
--  MINE ORE (NO SKILL CHECK VERSION)
------------------------------------------------------------
local function mineOre(zoneId, oreId, useSkillCheck)
    if not zoneId or not oreId then return end

    local zone = shared.mining.zones[zoneId]
    if not zone then return end

    local ore = ores[zoneId] and ores[zoneId][oreId]
    if not ore or not DoesEntityExist(ore.entity) then 
        if not useSkillCheck and isMacroMining then
            isMacroMining = false
            macroPosition = nil
            FreezeEntityPosition(cache.ped, false)
            ShowNotification('Ore no longer available. Macro mining stopped.', 'error')
        end
        return 
    end

    ------------------------------------------------------------
    -- LEVEL CHECK
    ------------------------------------------------------------
    local level = mining:GetPlayerData('level')
    if level < zone.level then
        ShowNotification(locale('notify.not-experienced'), 'error')
        if not useSkillCheck then
            isMacroMining = false
            macroPosition = nil
            FreezeEntityPosition(cache.ped, false)
        end
        return
    end

    ------------------------------------------------------------
    -- PICKAXE CHECK
    ------------------------------------------------------------
    local pickaxe, item = false, nil
    for pick_level, pick_data in pairs(shared.pickaxes) do
        if pick_level <= level and HasItem(pick_data.item, 1) then
            pickaxe, item = true, pick_data.item
            break
        end
    end
    if not pickaxe then
        ShowNotification(locale('notify.missing-pickaxe'), 'error')
        if not useSkillCheck then
            isMacroMining = false
            macroPosition = nil
            FreezeEntityPosition(cache.ped, false)
        end
        return
    end

    ------------------------------------------------------------
    -- DURABILITY CHECK
    ------------------------------------------------------------
    local metadata = lib.callback.await('lation_mining:getmetadata', false, item)
    local metatype = GetDurabilityType()
    local degrade = shared.pickaxes[level].degrade

    if not metadata or not metadata[metatype] or metadata[metatype] < degrade then
        ShowNotification(locale('notify.pickaxe-no-durability'), 'error')
        if not useSkillCheck then
            isMacroMining = false
            macroPosition = nil
            FreezeEntityPosition(cache.ped, false)
        end
        return
    end

    ------------------------------------------------------------
    -- TIME OF DAY CHECK
    ------------------------------------------------------------
    local hour = GetClockHours()
    local hours = shared.mining.hours
    if hour < hours.min or hour > hours.max then
        ShowNotification(locale('notify.nighttime'), 'error')
        if not useSkillCheck then
            isMacroMining = false
            macroPosition = nil
            FreezeEntityPosition(cache.ped, false)
        end
        return
    end

    ------------------------------------------------------------
    -- DURATION CALCULATION
    ------------------------------------------------------------
    local duration = math.random(zone.duration.min, zone.duration.max)

    if useSkillCheck then
        -- Normal mining still uses pickaxe speed multiplier
        local speed = shared.pickaxes[level].speedMultiplier or 1.0
        duration = math.floor(duration * speed)
    else
        -- Macro mining always 3× slower
        duration = duration * 3.0
    end

    local anim = client.anims.mining
    anim.duration = duration

    ------------------------------------------------------------
    -- FREEZE PLAYER FOR MACRO
    ------------------------------------------------------------
    if not useSkillCheck then
        if not macroPosition then
            macroPosition = GetEntityCoords(cache.ped)
        end
        FreezeEntityPosition(cache.ped, true)
    end

    ------------------------------------------------------------
    -- PROGRESS BAR
    ------------------------------------------------------------
    if ProgressBar(anim) then

        ------------------------------------------------------------
        -- SKILL CHECK REMOVED — ALWAYS SUCCESS
        ------------------------------------------------------------
        local success = true

        if success then
            DeleteEntity(ore.entity)
            ores[zoneId][oreId] = { respawn = GetGameTimer() + zone.respawn }
            TriggerServerEvent('lation_mining:minedore', zoneId, oreId)

            ------------------------------------------------------------
            -- MACRO MINING LOOP
            ------------------------------------------------------------
            if not useSkillCheck and isMacroMining then
                if macroPosition then
                    SetEntityCoords(cache.ped, macroPosition.x, macroPosition.y, macroPosition.z, false, false, false, false)
                end
                
                SetTimeout(500, function()
                    if isMacroMining then
                        local waitTime = 0

                        while isMacroMining and waitTime < zone.respawn do
                            Wait(1000)
                            waitTime = waitTime + 1000
                        end

                        Wait(1500)

                        local currentOre = ores[zoneId] and ores[zoneId][oreId]

                        if currentOre and DoesEntityExist(currentOre.entity) then
                            if macroPosition then
                                SetEntityCoords(cache.ped, macroPosition.x, macroPosition.y, macroPosition.z, false, false, false, false)
                            end
                            mineOre(currentMacroZone, currentMacroOre, false)
                            return
                        end

                        if isMacroMining then
                            isMacroMining = false
                            macroPosition = nil
                            FreezeEntityPosition(cache.ped, false)
                            ShowNotification('Ore respawn timeout. Macro mining stopped.', 'error')
                        end
                    end
                end)
            else
                FreezeEntityPosition(cache.ped, false)
            end
        end
    else
        if not useSkillCheck then
            FreezeEntityPosition(cache.ped, false)
            isMacroMining = false
            macroPosition = nil
            ShowNotification('Macro mining cancelled', 'error')
        end
    end
end

------------------------------------------------------------
--  MINING MENU (NO SKILL CHECK)
------------------------------------------------------------
local function showMiningMenu(zoneId, oreId)
    lib.registerContext({
        id = 'mining_mode_menu',
        title = 'Mining Options',
        options = {
            {
                title = 'Normal Mining',
                description = 'Fast mining (no skill check)',
                icon = 'hammer',
                iconColor = '#3b82f6',
                onSelect = function()
                    mineOre(zoneId, oreId, false)
                end
            },
            {
                title = 'Macro Mining (AFK)',
                description = '3× Slower, No Skill Checks',
                icon = 'robot',
                iconColor = '#8b5cf6',
                onSelect = function()
                    isMacroMining = true
                    currentMacroZone = zoneId
                    currentMacroOre = oreId
                    macroPosition = GetEntityCoords(cache.ped)
                    ShowNotification('Macro mining started. Use /stopmining to stop', 'success')
                    mineOre(zoneId, oreId, false)
                end
            }
        }
    })
    lib.showContext('mining_mode_menu')
end

------------------------------------------------------------
-- STOP MACRO COMMAND
------------------------------------------------------------
RegisterCommand('stopmining', function()
    if isMacroMining then
        isMacroMining = false
        currentMacroZone = nil
        currentMacroOre = nil
        macroPosition = nil
        FreezeEntityPosition(cache.ped, false)
        ShowNotification('Macro mining stopped', 'inform')
    else
        ShowNotification('You are not macro mining', 'error')
    end
end, false)

------------------------------------------------------------
-- SPAWN ORE
------------------------------------------------------------
local function spawnOre(zoneId, oreId)
    local zone = shared.mining.zones[zoneId]
    if not zone then return end

    local ore = zone.ores[oreId]
    if not ore then return end

    local models = zone.models
    local model = models[math.random(#models)]

    lib.requestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local entity = CreateObject(model, ore.x, ore.y, ore.z, false, false, false)
    PlaceObjectOnGroundProperly(entity)
    FreezeEntityPosition(entity, true)

    AddTargetEntity(entity, {
        {
            name = zoneId .. oreId,
            label = locale('target.mine-ore'),
            icon = icons.mine,
            iconColor = icons.mine_color,
            distance = 2,
            canInteract = function()
                return not IsPedInAnyVehicle(cache.ped, true) and not isMacroMining
            end,
            onSelect = function()
                showMiningMenu(zoneId, oreId)
            end
        }
    })

    ores[zoneId][oreId] = { entity = entity, respawn = nil }
end

------------------------------------------------------------
-- ENTER MINE
------------------------------------------------------------
local function enterMine()
    inside = true
    for zoneId, zone in pairs(shared.mining.zones) do
        ores[zoneId] = {}
        for oreId, _ in pairs(zone.ores) do
            spawnOre(zoneId, oreId)
        end
    end
end

------------------------------------------------------------
-- EXIT MINE
------------------------------------------------------------
local function exitMine()
    inside = false
    isMacroMining = false
    macroPosition = nil
    FreezeEntityPosition(cache.ped, false)

    for zoneId, oreData in pairs(ores) do
        for _, data in pairs(oreData) do
            if data.entity and DoesEntityExist(data.entity) then
                DeleteEntity(data.entity)
            end
        end
    end

    ores = {}
end

------------------------------------------------------------
-- RESPAWN THREAD
------------------------------------------------------------
CreateThread(function()
    while true do
        if inside then
            for zoneId, oreData in pairs(ores) do
                for oreId, data in pairs(oreData) do
                    if data.respawn and GetGameTimer() >= data.respawn then
                        spawnOre(zoneId, oreId)
                    end
                end
            end
            Wait(1000)
        else
            Wait(10000)
        end
    end
end)

------------------------------------------------------------
-- PLAYER LOADED
------------------------------------------------------------
AddEventHandler('lation_mining:onPlayerLoaded', function()
    lib.zones.sphere({
        coords = shared.mining.center,
        radius = 400,
        onEnter = enterMine,
        onExit = exitMine,
        debug = shared.setup.debug
    })
end)

------------------------------------------------------------
-- RESOURCE STOP CLEANUP
------------------------------------------------------------
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    isMacroMining = false
    macroPosition = nil
    FreezeEntityPosition(cache.ped, false)

    for zoneId, oreData in pairs(ores) do
        for _, data in pairs(oreData) do
            if data.entity and DoesEntityExist(data.entity) then
                DeleteEntity(data.entity)
            end
        end
    end
end)
