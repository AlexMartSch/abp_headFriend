--[[

           ____  _____        _____                 _                                  _       
     /\   |  _ \|  __ \      |  __ \               | |                                | |      
    /  \  | |_) | |__) |_____| |  | | _____   _____| | ___  _ __  _ __ ___   ___ _ __ | |_ ___ 
   / /\ \ |  _ <|  ___/______| |  | |/ _ \ \ / / _ \ |/ _ \| '_ \| '_ ` _ \ / _ \ '_ \| __/ __|
  / ____ \| |_) | |          | |__| |  __/\ V /  __/ | (_) | |_) | | | | | |  __/ | | | |_\__ \
 /_/    \_\____/|_|          |_____/ \___| \_/ \___|_|\___/| .__/|_| |_| |_|\___|_| |_|\__|___/
                                                           | |                                 
                                                           |_|                                 

    Supported version 2023
    Support Discord: https://discord.gg/NQFSD6t9hQ

]]


-- Implement your custom logic to get admins.
function isAdmin(source)
    return false
end

-------------------------------
--  This function will make if you have 'Config.FriendAPI_UseCustomId' enabled, select your framework's custom identifier.
--  Set this option if you do NOT want to work with the STEAM identifier, for example if you have more than one character or just want to change it.
------------------
function getUserIdentifier(source)
    local myCustomPlayerId = "abc123"
    return myCustomPlayerId
end

-------------------------------
--  If you do NOT want to use the Steam name as an overhead display, then manually set what you want to display.
------------------
function getUserHeadName(source)
    return GetPlayerName(source)
end


----- Check some Snippets for QBCore in: https://discord.com/channels/1103383170285584485/1120207101596274718 & https://discord.com/channels/1103383170285584485/1114093571960741961
---- You can make your own changes for this code.