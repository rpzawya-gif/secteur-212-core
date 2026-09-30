fx_version 'cerulean'
game 'gta5'

lua54 'yes'

shared_scripts {
    'shared/config.lua',
    'shared/jobs.lua'
}

client_scripts {
    'client/main.lua',
    'client/hud.lua',
    'client/jobs.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/permissions.lua',
    'server/player_functions.lua',
    'server/jobs.lua',
    'server/paycheck.lua',
    'server/usables.lua',
    'server/main.lua'
}

export 'GetCoreObject'
