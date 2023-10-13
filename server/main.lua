local adminModeList = {}

local getUserId = function(source)
    local result = nil
    if Config.Framework == "standalone" then
        for k, v in pairs(GetPlayerIdentifiers(source)) do
            if string.sub(v, 1, string.len("license:")) == "license:" then
                result = v
                break
            end
        end
    else
        result = GetUserIdentifier(source)
    end

    return tostring(result)
end

local getUserIds = function(source)
    local result = {}
    for k, v in pairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, string.len("license:")) == "license:" then
            result['license'] = v
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            result['discord'] = v
        end
    end

    return result
end

local checkIfAdmin = function(source)
    if Config.UseAdminList then
        local user = getUserIds(source)
        local hasAccess = false
        for k, license in pairs(Config.AdminLicenseList) do
            if user.license == license then
                hasAccess = true
                break
            end
        end

        if not hasAccess then
            return isAdmin(source)
        end

        return hasAccess
    else
        return isAdmin(source)
    end
end

--- Friend API

local FriendAPI = {}
local playersCache = {}
local recentFriendRequests = {}

FriendAPI.Settings = {
    RequestTimeout = Config.FriendAPI_RequestTimeout
}


FriendAPI.AreFriend = function(from, to)
    local row = MySQL.single.await('SELECT * FROM abp_friends WHERE (friend_a = :friendA AND friend_b = :friendB) OR (friend_a = :friendB AND friend_b = :friendA)', {friendA = from, friendB = to})
    if row then
        return true
    end

    return false
end

FriendAPI.SendFriendRequest = function(from, to)
    if not Config.UseKVPInsteadDatabase then
        local currentTime = os.time()
        local timestamp = currentTime + Config.FriendAPI_RequestTimeout

        local dateTable = os.date("*t", timestamp)
        local formattedDate = string.format("%04d-%02d-%02d %02d:%02d:%02d", dateTable.year, dateTable.month, dateTable.day, dateTable.hour, dateTable.min, dateTable.sec)


        local id = MySQL.insert.await('INSERT INTO abp_friends_request (friend_a, friend_b, expires_at) VALUES (?, ?, ?)', {from, to, formattedDate})
        if id then
            return id
        end

        return false
    else
        return true
    end
end

FriendAPI.FindPendingRequests = function(from, to)
    local rows = MySQL.query.await([[SELECT *
    FROM abp_friends_request
    WHERE expires = 0
        AND ((friend_a = :friendA AND friend_b = :friendB) OR (friend_a = :friendB AND friend_b = :friendA))
        AND expires_at > NOW()]], {friendA = from, friendB = to})
    return #rows > 0 and true or false
end

FriendAPI.UpdateFriendRequest = function(id)
    local affectedRows = MySQL.update.await('UPDATE abp_friends_request SET expires = 1 WHERE id = ?', {id})
    if affectedRows > 0 then
        return true
    end

    return false
end

lib.callback.register('abp_headFriend:tryRegisterStaffMode', function(source) 
    if checkIfAdmin(source) then
        local existRecord = adminModeList[source]
        if existRecord then
            adminModeList[source].text = not adminModeList[source].text
        else
            adminModeList[source] = {
                hide = false,
                text = true
            }
        end

        TriggerClientEvent('abp_headFriend::SyncAdminMode', -1, adminModeList)
        return true, adminModeList
    end

    return false, {}
end)

lib.callback.register('abp_headFriend:tryRegisterHideMe', function(source) 
    if checkIfAdmin(source) then
        local existRecord = adminModeList[source]
        if existRecord then
            adminModeList[source].hide = not adminModeList[source].hide
        else
            adminModeList[source] = {
                hide = true,
                text = false
            }
        end

        TriggerClientEvent('abp_headFriend::SyncAdminMode', -1, adminModeList)
        return true, adminModeList
    end

    return false, {}
end)

lib.callback.register('abp_headFriend:CancelFriendship', function(source, friendshipId, targetPlayer) 
    if not Config.UseKVPInsteadDatabase then
        local localUserIdentifier = getUserId(source)
        local targetUserIdentifire = getUserId(targetPlayer)

        playersCache[localUserIdentifier]:RemoveFriend(friendshipId)
        playersCache[targetUserIdentifire]:FillFriends()

        return true
    else
        TriggerClientEvent('abp_headFriend:OnCanceledFriendship', targetPlayer, source)
        return true
    end
end)

function RequestFriendsOf(identifier)
    local dbFriends = MySQL.query.await('SELECT * FROM abp_friends WHERE (friend_a = :friendA OR friend_b = :friendB)', {friendA = identifier, friendB = identifier})
    local myFriends = {}

    for _, dFriend in pairs(dbFriends) do
        local friend = nil
        if dFriend.friend_a == identifier then
            friend = dFriend.friend_b
        else
            friend = dFriend.friend_a
        end

        local player = playersCache[friend]
        if player then
            table.insert(myFriends, player)
        end
    end

    return myFriends
end

--- Re-enchanted method
lib.callback.register('abp_headFriend:RequestMyFriends', function(source)
    local userIdentificator = getUserId(source)
    
    local Player = playersCache[userIdentificator]

    if Config.FriendAPI_RefreshDisplayName then
        Player:UpdateHeadText()
    end

    local friends = Player:GetFriends()
    local myFriends = {}
    
    for friendIndex, friend in pairs(friends) do
        if playersCache[friend.identifier] then
            local friendCache = playersCache[friend.identifier]

            myFriends[friendIndex] = {
                friendshipId = friend.id,
                headtext = friendCache.displayname,
                unknown = friendCache.unknown,
                playerId = friendCache.playerId
            }
        end
    end

    

    return myFriends--, #dbFriends
end)


lib.callback.register('abp_headFriend:RequestFriendship', function(source, playerTarget)
    
    local targetId = getUserId(playerTarget)
    local localId  = getUserId(source)

    if targetId == localId then
        TriggerClientEvent('abp_headFriend:notify', source, {
            title = Translate("FRIENDSHIP"),
            description = Translate("REQUEST_MYSELF"),
            type = "error"
        }) 
        return false
    end

    if recentFriendRequests[localId] and recentFriendRequests[localId] > GetGameTimer() then
        TriggerClientEvent('abp_headFriend:notify', source, {
            title = Translate("FRIENDSHIP"),
            description = Translate("REQUEST_TIMEOUT"),
            type = "error"
        })
        return false
    end

    if not Config.UseKVPInsteadDatabase then
        if FriendAPI.AreFriend(targetId, localId) then
            TriggerClientEvent('abp_headFriend:notify', source, {
                title = Translate("FRIENDSHIP"),
                description = Translate("REQUEST_ALREADY_FRIEND"),
                type = "error"
            })
            return false
        end
    end

    if not FriendAPI.FindPendingRequests(targetId, localId) then
        local id = FriendAPI.SendFriendRequest(localId, targetId)

        if id then
            recentFriendRequests[localId] = (GetGameTimer() + (Config.FriendAPI_AntiSpamTimer * 1000))

            TriggerClientEvent('abp_headFriend:notify', source, {
                title = Translate("FRIENDSHIP"),
                description = Translate("REQUEST_SENDED"),
                type = "success"
            })

            local playerHeadTxt = GetUserHeadName(source)
            local targetHeadTxt = GetUserHeadName(playerTarget)

            local isAccepted = lib.callback.await('abp_headFriend:onRequestFriendship', playerTarget, Config.FriendAPI_UseUserHeadNameInsteadSteamNameOnFriendRequest and playerHeadTxt or GetPlayerName(source), id)
            if isAccepted then

                local success  = playersCache[localId]:AddFriend(targetId)
                local success2 = playersCache[targetId]:FillFriends()

                if success and success2 then
                    TriggerClientEvent('ox_lib:notify', source, {
                        title = Translate("FRIENDSHIP"),
                        description = Translate("REQUEST_ACCEPTED", targetHeadTxt),
                        type = "success"
                    })

                    TriggerClientEvent('ox_lib:notify', playerTarget, {
                        title = Translate("FRIENDSHIP"),
                        description = Translate("REQUEST_ACCEPTED", playerHeadTxt),
                        type = "success"
                    })
                end

                return true, playersCache[localId]:GetFriends()
            end

            if not Config.UseKVPInsteadDatabase then
                FriendAPI.UpdateFriendRequest(id)
            end
        end
    else
        TriggerClientEvent('abp_headFriend:notify', source, {
            title = Translate("FRIENDSHIP"),
            description = Translate("REQUEST_PENDING"),
            type = "warning"
        })
    end

    return false
    
end)


-- Re-enchanted method
lib.callback.register('abp_headFriend:RequestPlayersCache', function(source) 
    return playersCache
end)


RegisterNetEvent('abp_headFriend::RegisterPlayer', function(playerSource)
    local src = playerSource or source
    local userIdentifier = getUserId(src)

    playersCache[userIdentifier] = Player:Register({
        identifier      = userIdentifier,
        displayname     = Config.FiendAPI_UseCustomHeadText and GetCustomHeadText(src) or GetPlayerName(src),
        unknown         = Config.FiendAPI_UseCustomHeadText and GetCustomUnknownHeadText(src) or Translate("UNKNOWN") ,
        playerId        = src,
        friends         = {}
    })

    playersCache[userIdentifier]:FillFriends()

    TriggerClientEvent('abp_headFriend::SyncCachePlayers', src, playersCache)
    TriggerClientEvent('abp_headFriend::SyncAdminMode', src, adminModeList)
end)



CreateThread(function()
    if not Config.UseKVPInsteadDatabase then
        print("[HeadFriend] You are using database storage.")
        MySQL.update('UPDATE abp_friends_request SET expires = 1')
    else
        print("[HeadFriend] You are using KVP storage.")

        CreateThread(function() 
            while true do

                TriggerClientEvent('abp_headFriend::SyncPlayers', -1, playersCache)
                
                Wait(Config.SyncKVPToClient * 1000)
            end
        end)
    end
end)

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------

function checkSetup()
    if Config.FriendAPI_UseCustomId then
        local identifier = GetUserIdentifier(-1)
        if identifier == "abc123" then
            print("[WARNING] Please setup 'GetUserIdentifier()' in custom functions.")
            print("[WARNING] This returns 'abc123' as the identifier, this will cause an error when making friends.")
        end
    end
end

checkSetup()