fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'jr_vehicleshop'
author 'HeisenbergJr49'
version '1.0.0'
description 'Modern Vehicle Shop System for ESX'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/images/*.png',
    'html/images/*.jpg',
    'html/images/*.webp'
}

dependencies {
    'es_extended',
    'oxmysql'
}