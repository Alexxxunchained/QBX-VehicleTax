fx_version 'cerulean'
game 'gta5'

description 'Vehicle Tax 车辆税费系统'
version '1.0.1'
author 'MySword傅剑寒'

shared_script {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_script {
    'client/main.lua'
}

lua54 'yes'
use_fxv2_oal 'yes'
