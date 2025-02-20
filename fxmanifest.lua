-- For support join the discord: https://discord.gg/Z9Mxu72zZ6

fx_version "cerulean"
game "gta5"
lua54 "yes"
use_experimental_fxv2_oal "yes"

author "Andy's Development Convert by Mekz1222"
description "Simple character selection for QBOX."
version "1.0.0"

files {
    "ui/jquery.min.js",
    "ui/map.jpg",
	"ui/index.html",
	"ui/script.js",
	"ui/style.css",
    "data/images/**",
    "data/**",
    "modules/**/client.lua"
}

ui_page "ui/index.html"

shared_scripts {
   "@ox_lib/init.lua",
   "@qbx_core/modules/playerdata.lua"
}

server_script {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua"
}
client_script "client/main.lua"
