Add this itens on Ox_inventory

```lua
	["reviver"] =
	{
		["label"] = "Reanimador",
		["description"] = "Revive pessoas gravemente feridas",
		["weight"] = 500,
		["image"] = "reviver",
		consume = 1,
		client = { export = 'frp_death_state.reviverItem' },
		server = { export = 'frp_death_state.reviverItem' },
	},

	-- REMÉDIOS                                 
	["tonico"]  = {
		["label"] = "Garrafa de Tonico",
		["description"] = "Garrafa cheia de Tonico",
		degrade = 15000,
		["weight"] = 500,
		["image"] = "tonico",
		consume = 0,
		server = { export = 'frp_death_state.itemTonic' },
	},

	["tonicop"] = {
		["label"] = "Garrafa de Tonico Potente",
		["description"] = "Garrafa cheia de Tonico Potente",
		degrade = 15000,
		["weight"] = 700,
		["image"] = "tonicoP",
		consume = 0,
		server = { export = 'frp_death_state.itemTonic' },
	},

	["medicine"] =
	{
		["label"] = "Remédio",
		["description"] = "Cura até os mais feridos",
		["weight"] = 700,
		["image"] = "medicine",
		degrade = 15000,
		consume = 1,
		client = { export = 'frp_death_state.itemMedicine' },
		server = { export = 'frp_death_state.itemMedicine' },
	},
```