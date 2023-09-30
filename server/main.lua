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
        result = getUserIdentifier(source)
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

FriendAPI.AddFriend = function(from, to)
    return MySQL.insert.await('INSERT INTO abp_friends (friend_a, friend_b) VALUES (?, ?)', {from, to})
end

FriendAPI.RemoveFriendship = function(id)
    local affectedRows = MySQL.query.await('DELETE FROM abp_friends WHERE id = ?', {id})
    if affectedRows then
        return true
    end

    return false
end

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

FriendAPI.IsRequestPending = function(id)
    local row = MySQL.single.await('SELECT expires FROM abp_friends_request WHERE id = ?', {id})
    if row then
        return row.expires
    end

    return false
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
        return FriendAPI.RemoveFriendship(friendshipId)
    else
        TriggerClientEvent('abp_headFriend:OnCanceledFriendship', targetPlayer, source)
        return true
    end
end)

lib.callback.register('abp_headFriend:RequestMyFriends', function(source)
    local userId = tostring(getUserId(source))
    local dbFriends = MySQL.query.await('SELECT * FROM abp_friends WHERE (friend_a = :friendA OR friend_b = :friendB)', {friendA = userId, friendB = userId})
    local myFriends = {}

    
    for friendIndex, friend in pairs(playersCache) do
        
        for _, dFriend in pairs(dbFriends) do
            if dFriend.friend_a == friend.identifier or dFriend.friend_b == friend.identifier then
                if friend.identifier ~= userId then
                    myFriends[friendIndex] = friend
                    myFriends[friendIndex].friendshipId = dFriend.id

                    if Config.FriendAPI_UseIdAfterHeadName and Config.FriendAPI_UseCustomIdAfterHeadName then
                        myFriends[friendIndex].customHeadtext = GetCustomHeadText(source)
                        myFriends[friendIndex].customHeadUnknownText = GetCustomUnknownHeadText(source)
                    end

                    break
                end
            end 
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

            local playerHeadTxt = getUserHeadName(playerTarget)

            local isAccepted = lib.callback.await('abp_headFriend:onRequestFriendship', playerTarget, Config.FriendAPI_UseUserHeadNameInsteadSteamNameOnFriendRequest and playerHeadTxt or GetPlayerName(source), id)
            if isAccepted then
                FriendAPI.AddFriend(localId, targetId)
                TriggerClientEvent('abp_headFriend:notify', source, {
                    title = Translate("FRIENDSHIP"),
                    description = Translate("REQUEST_ACCEPTED", targetId),
                    type = "success"
                })

                

                if not playerHeadTxt or playerHeadTxt == nil then
                    playerHeadTxt = GetPlayerName(playerTarget)
                end

                return true, playerHeadTxt, targetId
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


RegisterNetEvent('abp_headFriend::RegisterPlayer', function(playerSource)
    local src = playerSource or source
    playersCache[src] = {
        identifier = getUserId(src),
        headtext   = getUserHeadName(src) or "Not Found",
        source     = src
    }

    if Config.FriendAPI_UseIdAfterHeadName and Config.FriendAPI_UseCustomIdAfterHeadName then
        playersCache[src].customHeadUnknownText = GetCustomUnknownHeadText(src)
    end

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
        local identifier = getUserIdentifier(-1)
        if identifier == "abc123" then
            print("[WARNING] Please setup 'getUserIdentifier()' in custom functions.")
            print("[WARNING] This returns 'abc123' as the identifier, this will cause an error when making friends.")
        end
    end
end

checkSetup()