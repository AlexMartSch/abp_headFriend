if Config.Framework ~= "qb" then
    return
end

print("Loaded QB-Core Configuration")
QBCORE = exports['qb-core']:GetCoreObject()

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

function IsAdmin(playerId)
    return QBCORE.Functions.HasPermission(playerId, 'admin')
end

-------------------------------
--  This function will make if you have 'Config.FriendAPI_UseCustomId' enabled, select your framework's custom identifier.
--  Set this option if you do NOT want to work with the STEAM identifier, for example if you have more than one character or just want to change it.
------------------
function GetUserIdentifier(source)
    local xPlayer = QBCORE.Functions.GetPlayer(source)
    if not xPlayer then return source end

    return xPlayer.PlayerData.citizenid
end

-------------------------------
--  If you do NOT want to use the Steam name as friend request, then manually set what you want to display.
------------------
function GetUserHeadName(playerId)
    local xPlayer = QBCORE.Functions.GetPlayer(playerId)
    if not xPlayer then GetPlayerName(source) end

    return GetCustomHeadText(playerId)
end

-------------------------------
-- In this function you can set it to fetch the player id, for example if you have an id corresponding to "#abc123" then you should use some function to get the player id and it will be displayed overhead.
------------------
function GetCustomHeadText(playerId)
    local xPlayer = QBCORE.Functions.GetPlayer(playerId)
    if not xPlayer then GetPlayerName(playerId) end

    local display = ("%s %s [%s]"):format(xPlayer.PlayerData.charinfo.firstname, xPlayer.PlayerData.charinfo.lastname, playerId)
    return display
end


function GetCustomUnknownHeadText(playerId)
    return Translate("UNKNOWN") .. " | " .. tostring(playerId)
end
------------------
