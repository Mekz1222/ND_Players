-- For support join the discord: https://discord.gg/Z9Mxu72zZ6

author "Andy & Geneva"
description "Simple character selection for ND Core"
version ""

fx_version "cerulean"
game "gta5"
lua54 "yes"

files {
	"ui/index.html",
	"ui/script.js",
	"ui/style.css"
}
ui_page "ui/index.html"

shared_script "config.lua"
server_script "source/server.lua"
client_script "source/client.lua"