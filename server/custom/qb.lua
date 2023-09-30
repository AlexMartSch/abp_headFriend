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

function isAdmin(source)
    return false
end

function getUserIdentifier(source)
    local xPlayer = QBCORE.Functions.GetPlayer(source)
    if not xPlayer then return source end

    return xPlayer.PlayerData.citizenid
end

function getUserHeadName(source)
    local xPlayer = QBCORE.Functions.GetPlayer(source)
    if not xPlayer then GetPlayerName(source) end

    return xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
end

-------------------------------
-- In this function you can set it to fetch the player id, for example if you have an id corresponding to "#abc123" then you should use some function to get the player id and it will be displayed overhead.
function GetCustomHeadText(playerId)
    return GetPlayerName(playerId) .. " | " .. tostring(math.random(1000, 9999))
end

---- WIP
function GetCustomUnknownHeadText(playerId)
    return Translate("UNKNOWN") .. " | " .. tostring(playerId)
end
------------------