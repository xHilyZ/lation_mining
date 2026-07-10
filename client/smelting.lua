-- Initialize config(s)
local shared = require 'config.shared'
local client = require 'config.client'
local icons  = require 'config.icons'

-- Localize export
local mining = exports.lation_mining

local menu = {}
local smelting = false

------------------------------------------------------------
-- SAFE LOADER THREAD (PREVENTS NIL ERRORS)
------------------------------------------------------------
CreateThread(function()
    -- Wait until shared.smelting exists
    while not shared.smelting do
        Wait(100)
    end

    -- Wait until ingots table exists
    while not shared.smelting.ingots do
        Wait(100)
    end

    -- Wait until ingots table is populated
    while next(shared.smelting.ingots) == nil do
        Wait(100)
    end

    -- Now safe to build menu + blip
    buildMenu()
    createBlip(shared.smelting.coords, shared.smelting.blip)
end)

------------------------------------------------------------
-- CREATE BLIP
------------------------------------------------------------
function createBlip(coords, data)
    if not data.enable then return end
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, data.sprite)
    SetBlipColour(blip, data.color)
    SetBlipScale(blip, data.scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.label)
    EndTextCommandSetBlipName(blip)
end

------------------------------------------------------------
-- BUILD MENU
------------------------------------------------------------
function buildMenu()
    menu = {}

    for ingotId, data in pairs(shared.smelting.ingots) do
        local desc = {}

        for _, req in ipairs(data.required) do
            local itemData = GetItemData(req.item)
            local label = itemData and itemData.label or req.item
            desc[#desc + 1] = string.format("x%d %s", req.quantity, label)
        end

        menu[#menu + 1] = {
            title = data.name,
            description = table.concat(desc, ', '),
            icon = data.icon,
            event = 'lation_mining:smelting:selectquantity',
            args = ingotId
        }
    end

    lib.registerContext({
        id = 'smelt-menu',
        title = locale('smelt-menu.main-title'),
        options = menu
    })
end

------------------------------------------------------------
-- START SMELTING
------------------------------------------------------------
function startSmelting(ingotId, count)
    if not ingotId or not count or count <= 0 then return end

    local ingot = shared.smelting.ingots[ingotId]
    if not ingot then
        ShowNotification("Invalid ingot type.", "error")
        return
    end

    local level = mining:GetPlayerData('level')
    if level < ingot.level then
        ShowNotification(locale('notify.not-experienced'), 'error')
        return
    end

    if count > ingot.max then
        ShowNotification(locale('notify.max-ingots', ingot.max), 'error')
        count = ingot.max
    end

    local smelted, saveprogress = 0, 0
    smelting = true

    for i = 1, count do
        if smelted >= ingot.max then break end

        local missing = false
        for _, req in pairs(ingot.required) do
            if not HasItem(req.item, req.quantity) then
                ShowNotification(locale('notify.missing-item'), 'error')
                missing = true
                break
            end
        end

        if missing then break end

        TaskStartScenarioInPlace(cache.ped, client.anims.smelting.scenario, -1, true)

        local start = GetGameTimer()
        local stop = start + ingot.duration

        while GetGameTimer() < stop do
            local elapsed = GetGameTimer() - start
            local progress = math.floor((elapsed / ingot.duration) * 100)

            if progress ~= saveprogress then
                saveprogress = progress
                ShowTextUI(locale('textui.smelt', i, count, progress), icons.smelting)
            end

            Wait(100)
        end

        smelted += 1
        TriggerServerEvent('lation_mining:completesmelt', ingotId)
    end

    ClearPedTasks(cache.ped)
    HideTextUI()
    smelting = false
end

------------------------------------------------------------
-- SELECT QUANTITY
------------------------------------------------------------
AddEventHandler('lation_mining:smelting:selectquantity', function(ingotId)
    if not ingotId then return end

    local ingot = shared.smelting.ingots[ingotId]
    if not ingot then
        ShowNotification("Invalid ingot type.", "error")
        return
    end

    local input = lib.inputDialog(ingot.name, {
        {
            type = 'number',
            icon = icons.input_quantity,
            label = locale('inputs.label'),
            description = locale('inputs.desc'),
            default = 1,
            required = true
        }
    })

    if not input or not input[1] then return end
    startSmelting(ingotId, input[1])
end)

------------------------------------------------------------
-- ZONE SETUP (AFTER SAFE LOADER)
------------------------------------------------------------
CreateThread(function()
    -- Wait until shared is loaded
    while not shared.smelting or not shared.smelting.coords do
        Wait(100)
    end

    lib.zones.sphere({
        coords = shared.smelting.coords,
        radius = 200,
        onEnter = function()
            AddCircleZone({
                coords = shared.smelting.coords,
                name = 'smelt-zone',
                radius = 3,
                debug = shared.setup.debug,
                options = {
                    {
                        name = 'smelt-zone',
                        label = locale('target.smelt-ore'),
                        icon = icons.smelt,
                        iconColor = icons.smelt_color,
                        distance = 2,
                        canInteract = function()
                            return not smelting
                        end,
                        onSelect = function()
                            lib.showContext('smelt-menu')
                        end
                    }
                }
            })
        end,
        onExit = function()
            RemoveCircleZone('smelt-zone')
        end,
        debug = shared.setup.debug
    })
end)
