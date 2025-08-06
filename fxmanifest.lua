fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'Atoshi'
description 'A simple framework for FiveM'
version '1.0.5'

-- zUI
ui_page 'zUI/web/build/index.html'

files {
    -- zUI
    'zUI/themes/*.json',
    'zUI/web/build/**/*',

    -- Addons
    'addons/weapons.meta'
}

shared_scripts {
    'config.lua',
    'init.lua',
    'exports.lua',

    -- Enums
    'shared/enums/color.lua',

    -- Libs
    'shared/libs/io.lua',
    'shared/libs/event.lua'
}

server_scripts {
    -- MySQL
    '@oxmysql/lib/MySQL.lua',

    -- Functions
    'server/functions/*.lua',

    -- Class
    'server/class/*.lua',

    -- Manager
    'server/manager/*.lua',

    -- Commands
    'server/commands/*.lua'
}

client_scripts {
    -- zUI
    'zUI/functions/triggerNuiEvent.lua',
    'zUI/common.lua',
    'zUI/functions/getTheme.lua',
    'zUI/functions/applyTheme.lua',
    'zUI/functions/showInfoBox.lua',
    'zUI/menu/items/*.lua',
    'zUI/menu/functions/*.lua',
    'zUI/menu/main.lua',

    -- Functions
    'client/functions/*.lua',

    -- Manager
    'client/manager/*.lua',

    -- Class
    'client/class/*.lua',

    -- Commands
    'client/commands/*.lua'
}

exports {
    -- Event
    'rm.Event.Register',
    'rm.Event.Trigger',
    'rm.Event.TriggerServer'
}

server_exports {
    -- Event
    'rm.Event.Register',
    'rm.Event.Trigger',
    'rm.Event.TriggerClient'
}