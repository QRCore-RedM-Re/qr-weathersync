game 'rdr3'
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

description 'qr-weathersync'

shared_scripts{
	'config.lua',
	'@qr-core/shared/locale.lua',
	'locales/en.lua'
}
client_scripts{ 'client/*.lua' }
server_scripts{ 'server/*.lua' }