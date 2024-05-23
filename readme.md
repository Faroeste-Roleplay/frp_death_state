Add this itens on Ox_inventory

```lua
	["reviver"] =
	{
		["label"] = "Reanimador",
		["description"] = "Revive pessoas gravemente feridas",
		["weight"] = 500,
		["image"] = "reviver",
		consume = 1,
		client = { export = 'player_death_state_machine.reviverItem' },
		server = { export = 'player_death_state_machine.reviverItem' },
	},

	-- REMÉDIOS                                 
	["tonico"]  = {
		["label"] = "Garrafa de Tonico",
		["description"] = "Garrafa cheia de Tonico",
		degrade = 15000,
		["weight"] = 500,
		["image"] = "tonico",
		consume = 0,
		server = { export = 'player_death_state_machine.itemTonic' },
	},

	["tonicop"] = {
		["label"] = "Garrafa de Tonico Potente",
		["description"] = "Garrafa cheia de Tonico Potente",
		degrade = 15000,
		["weight"] = 700,
		["image"] = "tonicoP",
		consume = 0,
		server = { export = 'player_death_state_machine.itemTonic' },
	},

	["medicine"] =
	{
		["label"] = "Remédio",
		["description"] = "Cura até os mais feridos",
		["weight"] = 700,
		["image"] = "medicine",
		degrade = 15000,
		consume = 1,
		client = { export = 'player_death_state_machine.itemMedicine' },
		server = { export = 'player_death_state_machine.itemMedicine' },
	},
```