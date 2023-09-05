resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX Craft System'

version '1.0.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/fa.lua',
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server/main.lua'
}

ui_page('client/html/index.html')

client_scripts {
	'@es_extended/locale.lua',
	-- '@NativeUI/NativeUI.lua',
	'locales/fa.lua',
	'config.lua',
	'client/main.lua',
	'client/create.lua',
}

files({
    'client/html/index.html',
    'client/html/script.js',
    'client/html/style.css',
	'client/html/iran.otf'
})


