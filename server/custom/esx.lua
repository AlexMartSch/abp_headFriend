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

function isAdmin(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    return xPlayer.getGroup() == "admin"
end

function getUserIdentifier(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return source end
    
    return xPlayer.identifier
end

function getUserHeadName(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return GetPlayerName(source) end
    
    return xPlayer.getName()
end