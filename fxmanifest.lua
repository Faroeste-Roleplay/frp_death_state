fx_version 'cerulean'

game 'rdr3'

lua54 'yes'

use_experimental_fxv2_oal 'yes'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

shared_scripts {
	"@frp_lib/library/linker.lua",
    
    'shared/trigger_type.lua',
    'shared/state_type.lua',
    'shared/state_type_locale.lua',

    'shared/helpers.lua',

    'shared/statebag.lua',
    'shared/statebag_interaction_revive.lua',
    'shared/statebag_interaction_apply_medicine.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@frp_logs/import.lua',
    
    'server/helpers.lua',

    'server/statebag_interaction_revive.lua',
    'server/statebag_interaction_apply_medicine.lua',

    'server/item_medicine.lua',

    'server/main.lua',
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

    'client/revive_item.lua',
    'client/item_medicine.lua',

    'client/main.lua',
}