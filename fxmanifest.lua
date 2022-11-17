-- For support join the discord: https://discord.gg/Z9Mxu72zZ6

author "Andy & Geneva"
description "Simple character selection for ND Core"
version ""

fx_version "cerulean"
game "gta5"
lua54 "yes"
use_experimental_fxv2_oal "yes"

files {
	"ui/index.html",
	"ui/script.js",
	"ui/style.css"
}
ui_page "ui/index.html"

shared_scripts {
    "@ox_lib/init.lua",
    "config.lua"
}
server_script "server/main.lua"
client_scripts {
    "client/functions.lua",
    "client/main.lua"
} 