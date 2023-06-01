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

-- KVP Local storage on the client
-- Warning: Changing this option when there are already records will prevent them from being loaded.
Config.UseKVPInsteadDatabase = false
-- If KVP local storage is enabled, it is necessary to sync the player's source, 
-- otherwise if the player reconnects they will not be able to identify themselves as a friend.
Config.SyncKVPToClient = 12 -- seconds

-----------------------

-- Command to hide the id above the head
Config.HideNamesCommand = 'hidefriends'
Config.HideNamesCommandEnabled = true


-- Config.AdminCommandName = "friends"
-- Config.EnableAdminCommandUsage = true
-- Config.UseAdminList = true
-- Config.AdminSteamList = {
--     "steam:110000108381d36"
-- }


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

-- Otherwise steamid will be used as default
Config.FriendAPI_UseCustomId = false

Config.FriendAPI_UseConfirmDialogInsteadOfKeys = true
Config.FriendAPI_KeyToAccept = 246
Config.FriendAPI_KeyToCancel = 45

-- If you are not friends, do you want to show a text above the head that says 'Unknown'?
Config.FriendAPI_HeadUnknownText = true
Config.FriendAPI_HeadViewDistance = 10

--Config.FriendAPI_UseRadialMenu = true
--Config.FriendAPI_UseTextUI = true
Config.FriendAPI_UseOxTarget = true

-- A quick wait filter after performing an action, is in seconds.
Config.FriendAPI_AntiSpamTimer = 5

