fx_version 'adamant'

description 'SXL-AC by Mizun17 & zNoxy15'

version '2.0'

game 'gta5'

ui_page "html/index.html"

client_scripts {
    '@menuv/menuv.lua',
    'configs/client_config.lua',
    'client/*.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'configs/server_config.lua',
    'server/main.lua'
}

files {
    'html/*.html',
    'html/*.js',
} 
