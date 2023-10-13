Player = {}
Player.__index = Player

function Player:Register(data)
    local _data = {
        identifier = data.identifier,
        displayname = data.displayname,
        unknown = data.unknown,
        playerId = data.playerId,
        friends = data.friends
    }

    setmetatable(_data, self)
    self.__index = self

    Debug('[Friends] Added player ('.. data.identifier ..') as ' .. data.displayname)

    return _data
end

function Player:FillFriends()
    local dbFriends = MySQL.query.await('SELECT * FROM abp_friends WHERE (friend_a = :friendA OR friend_b = :friendB)', {friendA = self.identifier, friendB = self.identifier})
    self.friends = {}
    
    for _, dbFriend in pairs(dbFriends) do

        if dbFriend.friend_a ~= self.identifier then
            table.insert(self.friends, {
                identifier = dbFriend.friend_a,
                id = dbFriend.id
            })
        end

        if dbFriend.friend_b ~= self.identifier then
            table.insert(self.friends, {
                identifier = dbFriend.friend_b,
                id = dbFriend.id
            })
        end
    end
end

function Player:GetIdentifier()
    return self.identifier
end

function Player:GetDisplayName()
    return self.displayname
end

function Player:GetPlayerId()
    return self.playerId
end

function Player:GetFriends()
    return self.friends
end

function Player:IsFriend(friendIdentifier)
    for _, friend in pairs(self.friends) do
        if friend == friendIdentifier then
            return true
        end
    end

    return false
end

function Player:SendFriendRequest(friendIdentifier)
    if not Config.UseKVPInsteadDatabase then
        local currentTime = os.time()
        local timestamp = currentTime + Config.FriendAPI_RequestTimeout

        local dateTable = os.date("*t", timestamp)
        local formattedDate = string.format("%04d-%02d-%02d %02d:%02d:%02d", dateTable.year, dateTable.month, dateTable.day, dateTable.hour, dateTable.min, dateTable.sec)


        local id = MySQL.insert.await('INSERT INTO abp_friends_request (friend_a, friend_b, expires_at) VALUES (?, ?, ?)', {self.identifier, friendIdentifier, formattedDate})
        if id then
            return id
        end

        return false
    else
        return true
    end
end


function Player:AddFriend(friendIdentifier)
    local row = MySQL.insert.await('INSERT INTO abp_friends (friend_a, friend_b) VALUES (?, ?)', {self.identifier, friendIdentifier})
    if row > 0 then
        table.insert(self.friends, {
            id = row,
            identifier = friendIdentifier
        })
        return true
    end

    return false
    
end

function Player:RemoveFriend(friendship)
    for i, friend in pairs(self.friends) do
        if friend.id == friendship then
            local affectedRows = MySQL.query.await('DELETE FROM abp_friends WHERE id = ?', {friendship})
            if affectedRows then
                table.remove(self.friends, i)
                return true
            end

            return false
        end
    end
end
