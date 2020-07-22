fx_version 'bodacious'
game 'gta5'

author 'KasperAPedersen'
description 'Swoop food markets'
version '1.0'

ui_page "public/index.html"

files {
    "public/index.html",
    "public/inc/styling/css/index.css",
    "public/inc/styling/js/index.js"
}

client_script{
    'client.lua'
}

server_script{
    '@vrp/lib/utils.lua',
    'server.lua'
}