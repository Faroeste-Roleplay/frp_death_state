fx_version 'cerulean'

game 'rdr3'

lua54 'yes'

-- use_experimental_fxv2_oal 'yes'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

shared_scripts {
	"@frp_lib/library/linker.lua",
    
    'shared/trigger_type.lua',
    'shared/state_type.lua',
    'shared/state_type_locale.lua',

    'shared/helpers.lua',

    -- 'shared/statebag.lua',
    -- 'shared/statebag_interaction_revive.lua',
    -- 'shared/statebag_interaction_apply_medicine.lua',

    
	'item-impl/statebag.lua',
	'item-impl/item_interaction.lua',

	--[[ item : medicine ]]
	'item-impl/item-medicine/state_applying_medicine.lua',

	--[[ item : reviver ]]
	'item-impl/item-reviver/state_reviving.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@frp_logs/import.lua',
    
    'server/helpers.lua',

    -- 'server/statebag_interaction_revive.lua',
    -- 'server/statebag_interaction_apply_medicine.lua',

    'server/item_medicine.lua',

    'server/main.lua',

    	--[[ item : medicine ]]
	'item-impl/item-medicine/server_state_applying_medicine.lua',
	'item-impl/item-medicine/server_item_medicine.lua',

	--[[ item : reviver ]]
	'item-impl/item-reviver/server_state_reviving.lua',
	'item-impl/item-reviver/server_item_reviver.lua',

	--[[ item : tonics ]]
	'item-impl/item-tonic/server_item_tonic.lua',

	'item-impl/server_main.lua',
}

client_scripts {
    'client/constants.lua',
    'client/cam_controller.lua',

    'client/postfx.lua',

    'client/state.lua',
    'client/state_builder.lua',
    'client/state_machine.lua',

    'client/state_type_alive.lua',
    'client/state_type_dead.lua',
    'client/state_type_incapacitated.lua',
    'client/state_type_respawn.lua',
    'client/state_type_wounded.lua',

    'client/strategy.lua',

    -- 'client/revive_item.lua',
    -- 'client/item_medicine.lua',

    'client/main.lua',

    'client/gamestateDeathStrategy.lua',

    
	--[[ item : medicine ]]
	'item-impl/item-medicine/client_item_medicine.lua',

	--[[ item : reviver ]]
	'item-impl/item-reviver/client_item_reviver.lua',
}