fx_version 'cerulean'

author 'AlexBanPer'
version '1.4.0'
game 'gta5'

lua54 'yes'

name 'ABP_HeadFriend'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
}

client_scripts {
    'client/**/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/**/*.lua'
}

files {
    'shared/locales/*.json',
}

dependencies {
    'oxmysql',
    'ox_lib'
}