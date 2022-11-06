Config = {}

Config.ShowBlips = true
Config.PromptKey = 0xE30CD707 -- R

Config.Objects = {
    ["cone"] = {model = `prop_roadcone02a`, freeze = false},
    ["barrier"] = {model = `prop_barrier_work06a`, freeze = true},
    ["roadsign"] = {model = `prop_snow_sign_road_06g`, freeze = true},
    ["tent"] = {model = `prop_gazebo_03`, freeze = true},
    ["light"] = {model = `prop_worklight_03b`, freeze = true},
}

Config.MaxSpikes = 5

Config.HandCuffItem = 'handcuffs'

Config.LicenseRank = 0

Config.Locations = {
    ["duty"] = {
        [1] = vector3(2507.53, -1301.41, 48.95), -- Saint Denis
        [2] = vector3(-768.03, -1266.37, 44.05), -- Blackwater
    },
    ["stash"] = {
        [1] = vector3(2497.01, -1301.2, 48.96), -- Saint Denis
        [2] = vector3(-766.55, -1271.61, 44.05), -- Blackwater
    },
    ["vehicle"] = {
        [1] = vector4(2493.22, -1321.87, 48.87, 271.06), -- Saint Denis
        [2] = vector4(-769.05, -1254.9, 43.4, 358.53) -- Blackwater
    },
    ["armory"] = {
        [1] = vector3(2494.53, -1304.32, 48.95), -- Saint Denis
        [2] = vector3(-764.86, -1272.4, 44.04), -- Blackwater
    },
    ["evidence"] = {
        [1] = vector3(2494.44, -1313.39, 48.95), -- Saint Denis
        [2] = vector3(-761.98, -1272.62, 44.05), -- Blackwater
    },
    ["stations"] = {
        [1] = {label = "Sheriff", coords = vector3(1360.88, -1301.53, 77.77)}, -- Rhodes
        [2] = {label = "Marshal HQ", coords = vector3(2501.83, -1309.04, 48.95)}, -- Saint Denis
        [3] = {label = "Marshal Field Office", coords = vector3(-760.47, -1269.14, 44.04)}, -- Blackwater
        [4] = {label = "Sheriff", coords = vector3(-1810.57, -350.91, 164.66)}, -- Strawberry
        [5] = {label = "Sheriff", coords = vector3(-275.65, 808.62, 119.38)}, --valentine
    },
}

Config.AuthorizedVehicles = {
	-- Grade 0
	[0] = {
		["policewagon01x"] = "Police Vagon",
	},
	-- Grade 1
	[1] = {
		["policewagon01x"] = "Police Vagon",
	},
	-- Grade 2
	[2] = {
		["policewagon01x"] = "Police Vagon",
	}
}

Config.WeaponHashes = {}

Config.ArmoryWhitelist = {}
Config.WhitelistedVehicles = {}

Config.Items = {
    label = "Marshal Armory",
    slots = 6,
    items = {
        {
            name = "weapon_revolver_cattleman",
            price = 0,
            amount = 1,
            info = {
                serie = "",
            },
            type = "weapon",
            slot = 1,
            authorizedJobGrades = {0, 1, 2}
        },
        {
            name = "weapon_repeater_winchester",
            price = 0,
            amount = 1,
            info = {
                serie = "",
            },
            type = "weapon",
            slot = 2,
            authorizedJobGrades = {0, 1, 2}
        },
        {
            name = "weapon_melee_lantern",
            price = 0,
            amount = 1,
            info = {},
            type = "weapon",
            slot = 3,
            authorizedJobGrades = {0, 1, 2}
        },
        {
            name = "weapon_lasso",
            price = 0,
            amount = 1,
            info = {},
            type = "item",
            slot = 4,
            authorizedJobGrades = {0, 1, 2}
        },
        {
            name = "ammo_revolver",
            price = 0,
            amount = 5,
            info = {},
            type = "item",
            slot = 5,
            authorizedJobGrades = {0, 1, 2}
        },
        {
            name = "ammo_repeater",
            price = 0,
            amount = 5,
            info = {},
            type = "item",
            slot = 6,
            authorizedJobGrades = {0, 1, 2}
        },
    }
}
