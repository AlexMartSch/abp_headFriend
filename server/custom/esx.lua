if Config.Framework ~= "esx" then
    return
end

print("Loaded ESX Configuration")
ESX = exports['es_extended']:getSharedObject()

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

function IsAdmin(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    return xPlayer.getGroup() == "admin"
end

function GetUserIdentifier(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    while not xPlayer do
        xPlayer = ESX.GetPlayerFromId(source)
        Wait(500)
    end
    
    return xPlayer.identifier
end

-------------------------------
--  If you do NOT want to use the Steam name as an overhead display, then manually set what you want to display.
------------------
function GetUserHeadName(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then GetPlayerName(playerId) end
    
    return GetCustomHeadText(playerId)
end

-------------------------------
-- In this function you can set it to fetch the player id, for example if you have an id corresponding to "#abc123" then you should use some function to get the player id and it will be displayed overhead.
function GetCustomHeadText(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)

    local display = ("%s [%s]"):format(xPlayer.getName(), source) 
    return display
end

function GetCustomUnknownHeadText(playerId)
    return Translate("UNKNOWN") .. " | " .. tostring(playerId)
end
------------------