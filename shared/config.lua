local debugTimer = GetGameTimer()
Config = {}

--[[

           ____  _____        _____                 _                                  _       
     /\   |  _ \|  __ \      |  __ \               | |                                | |      
    /  \  | |_) | |__) |_____| |  | | _____   _____| | ___  _ __  _ __ ___   ___ _ __ | |_ ___ 
   / /\ \ |  _ <|  ___/______| |  | |/ _ \ \ / / _ \ |/ _ \| '_ \| '_ ` _ \ / _ \ '_ \| __/ __|
  / ____ \| |_) | |          | |__| |  __/\ V /  __/ | (_) | |_) | | | | | |  __/ | | | |_\__ \
 /_/    \_\____/|_|          |_____/ \___| \_/ \___|_|\___/| .__/|_| |_| |_|\___|_| |_|\__|___/
                                                           | |                                 
                                                           |_|                                 

    Supported version May 2023
    Support Discord: https://discord.gg/NQFSD6t9hQ

]]

-----------------------
--- GENERAL SETTINGS ---
-----------------------

-- Note: Use the name of the file as language. [es].json | [en].json
Config.Language = 'en'

Config.DebugMode = false

--- Current Supported options:
--- 'esx' ES Extended
--- 'qb'  QB-Core
--- 'standalone' Standalone configuration 
Config.Framework = GetResourceState('es_extended') and 'esx' or GetResourceState('qb-core') and 'qb' or 'standalone'

-- KVP Local storage on the client
-- Warning: Changing this option when there are already records will prevent them from being loaded.
Config.UseKVPInsteadDatabase = false
-- If KVP local storage is enabled, it is necessary to sync the player's source, 
-- otherwise if the player reconnects they will not be able to identify themselves as a friend.
Config.SyncKVPToClient = 12 -- seconds



local function detectFrameworkEvent()
    if Config.Framework == 'esx' then
        return 'esx:playerLoaded'
    elseif Config.Framework == 'qb' then
        return 'QBCore:Client:OnPlayerLoaded'
    else
        return nil
    end
end
Config.PlayerLoadEvent = detectFrameworkEvent()

-----------------------

-- Command to hide the id above the head
Config.HideNamesCommand = 'hidefriends'
Config.HideNamesCommandEnabled = true

-- Admin modes is: Set text over your head with a custom 'staff' title.
Config.EnableAdminMode = true
Config.AdminModeCommandName = "friendmin"
Config.AdminModeText = "Staff"
Config.AdminHideMeCommandName = "hideme"


Config.UseAdminList = true
Config.AdminLicenseList = {
    "license:abc123"
}


-----------------------
--- FRIEND MENU ---
-----------------------
--
    --[[ Integrated menu to view, add or remove friends. ]]
--
Config.FriendMenu_CommandName = 'friends'
Config.FriendMenu_CommandEnabled = true
Config.FriendMenu_Position = "bottom-right"

Config.FriendMenu_CanAddFriends = true
-- If this option is enabled, the system will check if the player is nearby when adding friends via the UI.
Config.FriendMenu_CanAddFriends_DistanceCheck = true
Config.FriendMenu_CanAddFriends_DistanceMax = 5

--Config.FriendMenu_CanSeeFriendsRequest = true
--Config.FriendMenu_CanSeePlayerStatus = true

-----------------------
--- FRIEND API ---
-----------------------

-- Friend requests have a valid death time so they are no more. How many seconds do you want an invitation to last?
Config.FriendAPI_RequestTimeout = 30

Config.FriendAPI_UseConfirmDialogInsteadOfKeys = true
Config.FriendAPI_KeyToAccept = 246
Config.FriendAPI_KeyToCancel = 45

-- If you are not friends, do you want to show a text above the head that says 'Unknown'?
Config.FriendAPI_HeadUnknownText = true
Config.FriendAPI_HeadViewDistance = 10
Config.FriendAPI_UseTalkingColor = true
Config.FriendAPI_TalkingColor = {
    R = 25,
    G = 255,
    B = 25
} -- R G B

-- Scale text overhead
Config.FriendAPI_TextScale = {
    Players = 1.5,
    AdminMode  = 1.6
}

--- This funcion includes 'Unknown' text if player is not friends.
Config.FiendAPI_UseCustomHeadText = true


-- On friendship request display SteamName or 'getUserHeadName' function
Config.FriendAPI_UseUserHeadNameInsteadSteamNameOnFriendRequest = true

-- Refresh displayname
Config.FriendAPI_RefreshDisplayName = true

--- Select a Target Resource 
-- 'ox' : OxTarget
-- 'qb' : QbTarget
--- IMPORTANT: OxLib always is required but PolyZone is required only to QBTarget.
Config.FriendAPI_TargetResource = 'ox'

-- A quick wait filter after performing an action, is in seconds.
Config.FriendAPI_AntiSpamTimer = 5

-- Activating this option will enable the raycast check to prevent the IdHead from appearing if there is an obstacle in the way.
Config.FriendAPI_UseRaycastForWalls = true

Config.HideOverheadTextInVehicle = true

-- If you want to 'hide' a head text when ped has any Mask (Mask section)
Config.UseMaskValidation = true
-- Advanced algorithm is a list of allowerd INDEX of clothes. This works when you have a custom clothes pack.
Config.MaskAdvancedValidationAlgorithm = false

-- List of allowed mask index, only works when 'MaskAdvancedValidationAlgorithm' its true.
Config.MaskAllowedList = {
    {1, 5}, -- A group of numbers (1, 2, 3, 4, 5)
    8, -- A Single number
    --10,
    --{15, 20}
}



-------------- DEBUG
function Debug(...)
    if Config.DebugMode then
        if debugTimer > GetGameTimer() then
            return
        end 
    
        debugTimer = GetGameTimer() + 1000
        print("[DEBUG] ", ...)
    end
end