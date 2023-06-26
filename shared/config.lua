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

--- Current Supported options:
--- 'esx' ES Extended
--- 'qb'  QB-Core
--- 'standalone' Standalone configuration 
Config.Framework = "standalone"

-- KVP Local storage on the client
-- Warning: Changing this option when there are already records will prevent them from being loaded.
Config.UseKVPInsteadDatabase = false
-- If KVP local storage is enabled, it is necessary to sync the player's source, 
-- otherwise if the player reconnects they will not be able to identify themselves as a friend.
Config.SyncKVPToClient = 12 -- seconds

-- Replace 'nil' for compatibility ESX, QBCore or any framework with the Player Load Event.
-- ESX:     'esx:playerLoaded'
-- QBCore: 'QBCore:Client:OnPlayerLoaded'

--- IMPORTANT: If you use any multicharacter, you must use an event that is called on the client once the player has loaded (after selecting their character) 
--- otherwise this could lead to errors when finding player settings.

-- IMPORTANT 2: If you don't know which event is correct, you can do the following:
-- Use this event [  abp_headFriend::RegisterPlayer  ] (SERVER SIDE) and use them on your multi-character resource when the player is connected (or loaded)
--      -- Please note the following, ABP will be able to guide you but does not promise to help you in case of custom resource errors.
--      -- If you have problems with your paid/free resource, consult your developer for assistance in how implements ABP Server Events.
--- Example: 
      -- MyMulticharacterScript -> server -> Player.Login() -> TriggerEvent('abp_headFriend::RegisterPlayer', source)

-- IMPORTANT 3: Keep nil if you use abp_headFriend::RegisterPlayer server event.
Config.PlayerLoadEvent = nil

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
Config.AdminSteamList = {
    "steam:110000108381d36"
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

-- If this option is TRUE, then it must be set in server/custom/functions.lua: getUserIdentifier()
-- Otherwise the steamID will be used automatically.
Config.FriendAPI_UseCustomId = false

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

-- For exmple: AlexBanPer #1 - Test Name #1 
-- Only if are friends. 
Config.FriendAPI_UseIdAfterHeadName = true

--- Select a Target Resource 
-- 'ox' : OxTarget
-- 'qb' : QbTarget
--- IMPORTANT: OxLib always is required but PolyZone is required only to QBTarget.
Config.FriendAPI_TargetResource = 'qb'

-- A quick wait filter after performing an action, is in seconds.
Config.FriendAPI_AntiSpamTimer = 5

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

