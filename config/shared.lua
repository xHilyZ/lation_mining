return {

    setup = {
        debug = false,
        interact = 'ox_target',
        notify = 'ox_lib',
        progress = 'ox_lib',
        version = true,
    },

    ----------------------------------------------
    -- EXPERIENCE LEVELS
    ----------------------------------------------

    experience = {
        [1] = 0,
        [2] = 2500,
        [3] = 10000,
        [4] = 20000,
        [5] = 500000,
        [6] = 650000,
        [7] = 750000,
        [8] = 950000,
    },

    ----------------------------------------------
    -- PICKAXES
    ----------------------------------------------

    pickaxes = {
        [1] = { item = 'ls_pickaxe', degrade = 1.0, speedMultiplier = 1.0 },
        [2] = { item = 'ls_copper_pickaxe', degrade = 0.75, speedMultiplier = 0.9 },
        [3] = { item = 'ls_iron_pickaxe', degrade = 0.5, speedMultiplier = 0.8 },
        [4] = { item = 'ls_silver_pickaxe', degrade = 0.25, speedMultiplier = 0.7 },
        [5] = { item = 'ls_gold_pickaxe', degrade = 0.1, speedMultiplier = 0.6 },
        [6] = { item = 'ls_emerald_pickaxe', degrade = 0.05, speedMultiplier = 0.5 },
        [7] = { item = 'ls_diamond_pickaxe', degrade = 0.01, speedMultiplier = 0.4 },
        [8] = { item = 'ls_unbreakable_pickaxe', degrade = 0.0, speedMultiplier = 0.3 },
    },

    ----------------------------------------------
    -- SHOPS
    ----------------------------------------------

    shops = {
        location = vec4(2943.1362, 2747.8320, 43.3318, 252.1999),
        model = 'a_m_m_farmer_01',
        scenario = 'WORLD_HUMAN_DRINKING',
        hours = { min = 0, max = 24 },

        mine = {
            enable = true,
            account = 'cash',
            items = {
                [1] = { item = 'ls_pickaxe', price = 5000, icon = 'hammer', metadata = { durability = 100 }, level = 1 },
                [2] = { item = 'ls_copper_pickaxe', price = 13000, icon = 'hammer', metadata = { durability = 100 }, level = 2 },
                [3] = { item = 'ls_iron_pickaxe', price = 15000, icon = 'hammer', metadata = { durability = 100 }, level = 3 },
                [4] = { item = 'ls_silver_pickaxe', price = 17500, icon = 'hammer', metadata = { durability = 100 }, level = 4 },
                [5] = { item = 'ls_gold_pickaxe', price = 25000, icon = 'hammer', metadata = { durability = 100 }, level = 5 },
                [6] = { item = 'ls_emerald_pickaxe', price = 50000, icon = 'hammer', metadata = { durability = 100 }, level = 6 },
                [7] = { item = 'ls_diamond_pickaxe', price = 100000, icon = 'hammer', metadata = { durability = 100 }, level = 7 },
                [8] = { item = 'ls_unbreakable_pickaxe', price = 2500000, icon = 'hammer', metadata = { durability = 100 }, level = 8 },
                [9] = { item = 'water', price = 1000, icon = 'droplet' },
                [10] = { item = 'burger', price = 1000, icon = 'burger' },
            },
        },

        pawn = {
            enable = true,
            account = 'cash',
            items = {
                [1] = { item = 'ls_coal_ore', price = 250, icon = 'hand-holding-dollar' },
                [2] = { item = 'ls_copper_ore', price = 300, icon = 'hand-holding-dollar' },
                [3] = { item = 'ls_iron_ore', price = 900, icon = 'hand-holding-dollar' },
                [4] = { item = 'ls_silver_ore', price = 1400, icon = 'hand-holding-dollar' },
                [5] = { item = 'ls_gold_ore', price = 2200, icon = 'hand-holding-dollar' },

                [6] = { item = 'ls_copper_ingot', price = 1500, icon = 'hand-holding-dollar' },
                [7] = { item = 'ls_iron_ingot', price = 3000, icon = 'hand-holding-dollar' },
                [8] = { item = 'ls_silver_ingot', price = 4500, icon = 'hand-holding-dollar' },
                [9] = { item = 'ls_gold_ingot', price = 7000, icon = 'hand-holding-dollar' },
            }
        },

        blip = {
            enable = true,
            sprite = 618,
            color = 5,
            scale = 0.6,
            label = 'The Mines'
        }
    },

    ----------------------------------------------
    -- MINING ZONES
    ----------------------------------------------

    mining = {
        center = vec3(2946.6995, 2792.2271, 40.5708),
        hours = { min = 0, max = 24 },

        zones = {
            [1] = {
                models = { 'prop_rock_3_b', 'prop_rock_3_d', 'prop_rock_3_f' },
                level = 1,
                duration = { min = 2500, max = 2500 },
                reward = { { item = 'ls_copper_ore', min = 2, max = 6 } },
                xp = { min = 20, max = 60 },
                respawn = 25000,
                ores = {
                    vec3(2949.8770, 2851.0256, 48.3509),
                    vec3(2955.0566, 2850.1597, 47.6026),
                    vec3(2959.4751, 2848.0740, 46.8103),
                    vec3(2952.2109, 2847.9136, 47.2530),
                    vec3(2956.3149, 2845.9241, 46.5613),
                    vec3(2947.4197, 2848.0171, 47.7500),
                    vec3(2961.4399, 2844.1255, 46.0608),
                }
            },

            [2] = {
                models = { 'prop_rock_3_b', 'prop_rock_3_d', 'prop_rock_3_f' },
                level = 1,
                duration = { min = 2500, max = 2500 },
                reward = { { item = 'ls_coal_ore', min = 2, max = 6 } },
                xp = { min = 20, max = 60 },
                respawn = 25000,
                ores = {
                    vec3(2938.3345, 2808.9683, 42.1674),
                    vec3(2930.3652, 2811.0193, 43.4722),
                    vec3(2925.0359, 2807.3450, 42.9333),
                    vec3(2927.2339, 2799.7976, 41.3330),
                    vec3(2930.2278, 2794.4519, 40.6447),
                    vec3(2935.8081, 2795.5881, 40.6888),
                    vec3(2940.8623, 2800.0393, 40.9543),
                    vec3(2935.3396, 2802.2466, 41.2976),
                    vec3(2932.2173, 2806.7004, 42.2299),
                    vec3(2941.5352, 2805.1804, 41.1859),
                }
            },

            [3] = {
                models = { 'prop_rock_3_b', 'prop_rock_3_d', 'prop_rock_3_f' },
                level = 2,
                duration = { min = 7500, max = 7500 },
                reward = { { item = 'ls_iron_ore', min = 2, max = 10 } },
                xp = { min = 40, max = 120 },
                respawn = 25000,
                ores = {
                    vec3(3027.8311, 2772.1812, 55.4793),
                    vec3(3030.8904, 2767.5234, 56.4680),
                    vec3(3028.2546, 2764.4390, 56.0667),
                    vec3(3030.5837, 2760.3337, 57.4613),
                    vec3(3025.9062, 2756.8679, 56.0076),
                    vec3(3026.0994, 2751.2605, 57.2785),
                    vec3(3020.6831, 2748.7808, 55.5372),
                }
            },

            [4] = {
                models = { 'prop_rock_3_b', 'prop_rock_3_d', 'prop_rock_3_f' },
                level = 3,
                duration = { min = 7500, max = 7500 },
                reward = { { item = 'ls_silver_ore', min = 2, max = 10 } },
                xp = { min = 60, max = 180 },
                respawn = 35000,
                ores = {
                    vec3(2969.4246, 2697.7976, 54.5088),
                    vec3(2966.6487, 2694.4221, 54.6609),
                    vec3(2962.9324, 2697.2637, 54.6642),
                    vec3(2953.2451, 2697.2317, 55.1387),
                    vec3(2950.2148, 2700.9580, 54.8590),
                }
            },

            [5] = {
                models = { 'prop_rock_3_b', 'prop_rock_3_d', 'prop_rock_3_f' },
                level = 4,
                duration = { min = 13000, max = 13000 },
                reward = { { item = 'ls_gold_ore', min = 2, max = 10 } },
                xp = { min = 80, max = 240 },
                respawn = 120000,
                ores = {
                    vec3(3041.3960, 2719.4390, 63.1831),
                    vec3(3047.6887, 2717.8809, 62.7571),
                    vec3(3045.9670, 2722.4072, 63.1737),
                    vec3(3052.4326, 2721.9761, 63.1375),
                    vec3(3052.2554, 2728.0950, 63.6344),
                    vec3(3058.0610, 2731.1460, 64.6821),
                    vec3(3055.9949, 2737.5295, 64.3239),
                    vec3(3060.6294, 2741.4951, 64.5270),
                    vec3(3058.5295, 2746.5312, 64.3540),
                    vec3(3060.2603, 2750.5828, 64.3339),
                }
            },
        }
    },

    ----------------------------------------------
    -- SMELTING (WITH BLIP ADDED)
    ----------------------------------------------

    smelting = {
        coords = vec3(1087.6827, -2002.1394, 31.4841),

        ingots = {
            [1] = {
                name = 'Copper Ingot',
                icon = 'fas fa-fire',
                level = 1,
                duration = 7500,
                max = 50,
                xp = { min = 30, max = 60 },
                required = {
                    { item = 'ls_coal_ore', quantity = 1 },
                    { item = 'ls_copper_ore', quantity = 1 },
                },
                add = {
                    { item = 'ls_copper_ingot', quantity = 1 },
                }
            },

            [2] = {
                name = 'Iron Ingot',
                icon = 'fas fa-fire',
                level = 2,
                duration = 9000,
                max = 50,
                xp = { min = 40, max = 80 },
                required = {
                    { item = 'ls_coal_ore', quantity = 3 },
                    { item = 'ls_iron_ore', quantity = 3 },
                },
                add = {
                    { item = 'ls_iron_ingot', quantity = 1 },
                }
            },

            [3] = {
                name = 'Silver Ingot',
                icon = 'fas fa-fire',
                level = 3,
                duration = 11000,
                max = 50,
                xp = { min = 50, max = 100 },
                required = {
                    { item = 'ls_coal_ore', quantity = 5 },
                    { item = 'ls_silver_ore', quantity = 5 },
                },
                add = {
                    { item = 'ls_silver_ingot', quantity = 1 },
                }
            },

            [4] = {
                name = 'Gold Ingot',
                icon = 'fas fa-fire',
                level = 4,
                duration = 13000,
                max = 50,
                xp = { min = 60, max = 120 },
                required = {
                    { item = 'ls_coal_ore', quantity = 5 },
                    { item = 'ls_gold_ore', quantity = 10 },
                },
                add = {
                    { item = 'ls_gold_ingot', quantity = 1 },
                }
            },
        },

        -- ⭐ Added Smelter Blip
        blip = {
            enable = true,
            sprite = 648,
            color = 17,
            scale = 0.6,
            label = 'Smelter'
        }
    }
}
