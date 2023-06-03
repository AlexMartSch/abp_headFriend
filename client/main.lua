local kvp = Config.UseKVPInsteadDatabase and GetResourceKvpString('friendships') or false

local FriendAPI = {}
FriendAPI.Friends = kvp and json.decode(kvp) or {}
FriendAPI.NearPlayers = {}
FriendAPI.ShowHeadText = true


local getFriendsCount = function()
    local counter = 0
    for _, friend in pairs(FriendAPI.Friends) do
        counter += 1
    end

    return counter
end

local areFriends = function(playerTarget)
    local result = false

    for _, friend in pairs(FriendAPI.Friends) do
        if friend.source == playerTarget then
            result = friend
            break
        end
    end

    return result
end

local removeFriend = function(playerTarget)
    local index = 0
    for i, friend in pairs(FriendAPI.Friends) do
        if friend.source == playerTarget then
            index = i
            break
        end
    end

    if index > 0 then
        FriendAPI.Friends[index] = nil
        return true
    end
    
    return false
end

local refreshKVPList = function(playersCache)
    for _, friend in pairs(playersCache) do
        for localFriendIndex, localFriend in pairs(FriendAPI.Friends) do
            if friend.identifier == localFriend.identifier then
                FriendAPI.Friends[localFriendIndex].source = friend.source
            end
        end
    end
end

RegisterNetEvent('abp_headFriend:notify', function(data) 
    lib.notify(data)
end)

RegisterNetEvent('abp_headFriend::SyncPlayers', function(pC) 
    refreshKVPList(pC)
end)

RegisterNetEvent('abp_headFriend:OnCanceledFriendship', function(targetPlayer)
    removeFriend(targetPlayer)
    SetResourceKvp('friendships', json.encode(FriendAPI.Friends))
end)

if Config.HideNamesCommandEnabled then

    RegisterCommand(Config.HideNamesCommand, function(source) 
        FriendAPI.ShowHeadText = not FriendAPI.ShowHeadText
    end)
    
end

if Config.FriendMenu_CommandEnabled then

    local options = {
        {
            label = "X"
        }
    }

    local friendsOptions = {}

    if Config.FriendMenu_CanAddFriends then
        table.insert(options, {
            label = "Add Friend",
            description = "Add friend by player id"
        })
    end

    -- if Config.FriendMenu_CanSeeFriendsRequest then
    --     table.insert(options, {
    --         label = "View Pending Requests",
    --         description = "Check your pending requests"
    --     })
    -- end

    local refillFriendList = function()
        
        for _, friend in pairs(FriendAPI.Friends) do
            table.insert(friendsOptions, {
                label = friend.headtext
            })
        end

        lib.setMenuOptions('abp::friend_menu_friendlist', friendsOptions)
    end


    lib.registerMenu({
        id = 'abp::friend_menu',
        title = Translate("FRIENDSHIP"),
        position = Config.FriendMenu_Position,
        options = options
    }, function(selected) 
        if selected == 1 then
            refillFriendList()
            lib.showMenu('abp::friend_menu_friendlist')
        elseif selected == 2 then
            local input = lib.inputDialog(Translate("MENU_INPUT_TITLE"), {
                {type = 'number', label = Translate("MENU_INPUT_LABEL"), description = Translate("MENU_INPUT_DESCRIPTION"), min = 1, icon = 'hashtag', required = true},
            }, {
                allowCancel = true
            })

            if input then
                local playerServerId = tonumber(input[1])

                if not playerServerId then
                    return lib.notify({
                        title = Translate("FRIENDSHIP"),
                        description = Translate("PLAYER_NOT_FOUND"),
                        type = "error"
                    })
                end

                if Config.FriendMenu_CanAddFriends_DistanceCheck then
                    local nearPlayers = lib.getNearbyPlayers(GetEntityCoords(PlayerPedId()), Config.FriendMenu_CanAddFriends_DistanceMax, true)
                    local playerFound = false

                    for _, player in pairs(nearPlayers) do
                        local foundServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(player.ped))
                        if playerServerId == foundServerId then
                            playerFound = true
                            break
                        end
                    end

                    if not playerFound then
                        return lib.notify({
                            title = Translate("FRIENDSHIP"),
                            description = Translate("Player not in area"),
                            type = "error"
                        })
                    end

                    local targetPlayer = playerServerId
                    if not FriendAPI.Friends[targetPlayer] then
                        local success, playerHeadText, identifier = lib.callback.await('abp_headFriend:RequestFriendship', false, targetPlayer)

                        if success then
                            FriendAPI.Friends[targetPlayer] = {headtext = playerHeadText, source = targetPlayer, identifier = identifier}

                            if Config.UseKVPInsteadDatabase then
                                SetResourceKvp('friendships', json.encode(FriendAPI.Friends))
                            end
                        end
                    else
                        lib.notify({
                            title = Translate("FRIENDSHIP"),
                            description = Translate("REQUEST_ALREADY_FRIEND"),
                            type = "error"
                        })
                    end
                    
                end
            end

        elseif selected == 3 then

        end
    end)

    lib.registerMenu({
        id = 'abp::friend_menu_friendlist',
        title = Translate("FRIENDSHIP"),
        position = Config.FriendMenu_Position,
        options = options
    }, function(selected) 
        
    end)

    RegisterCommand(Config.FriendMenu_CommandName, function(source)
        lib.setMenuOptions('abp::friend_menu', {
            label = Translate("FRIEND_COUNT", getFriendsCount())
        }, 1)

        lib.showMenu('abp::friend_menu')
    end)
end

if Config.FriendAPI_TargetResource == 'qb' then
    local targeting = exports['qb-target']

    targeting:AddGlobalPlayer({
        options = {
            {
                icon = "fas fa-hand",
                label = Translate("REQUEST_FRIENDSHIP"),
                action = function(entity)
                    local targetPlayer = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    local success, playerHeadText, identifier = lib.callback.await('abp_headFriend:RequestFriendship', false, targetPlayer)
    
                    if success then
                        FriendAPI.Friends[targetPlayer] = {headtext = playerHeadText, source = targetPlayer, identifier = identifier}
                        if Config.UseKVPInsteadDatabase then
                            SetResourceKvp('friendships', json.encode(FriendAPI.Friends))
                        end
                    end
                end,
                canInteract = function(entity, distance, data)
                    local targetPlayer = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    local isFriendOf = areFriends(targetPlayer) and true or false
                    print(2,isFriendOf)
                    return not isFriendOf
                end
            },
            {
                icon = "fas fa-hand",
                label = Translate("CANCEL_FRIENDSHIP"),
                action = function(entity)
                    local alert = lib.alertDialog({
                        header = Translate("REQUEST_CANCEL_FRIENDSHIP"),
                        content = Translate("REQUEST_CANCEL_FRIENDSHIP_TEXT"),
                        centered = true,
                        cancel = true
                    })
    
                    if alert == "confirm" then
                        local targetPlayer = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                        local success = lib.callback.await('abp_headFriend:CancelFriendship', false, areFriends(targetPlayer).friendshipId, targetPlayer)
    
                        if success then
                            removeFriend(targetPlayer)
    
                            if Config.UseKVPInsteadDatabase then
                                SetResourceKvp('friendships', json.encode(FriendAPI.Friends))
                            end
    
                            lib.notify({
                                title = Translate("FRIENDSHIP"),
                                description = Translate("REQUEST_CANCEL_SUCCESS"),
                                type = "success"
                            })
                        end
                    end
                end,
                canInteract = function(entity)
                    local targetPlayer = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    local isFriendOf = areFriends(targetPlayer) and true or false
                    print(1,isFriendOf)
                    return isFriendOf
                end
            },
        },
        distance = 2
    })
end

if Config.FriendAPI_TargetResource == "ox" then

    exports.ox_target:addGlobalPlayer({
        {
            icon = "fas fa-hand",
            label = Translate("REQUEST_FRIENDSHIP"),
            onSelect = function(data)
                local targetPlayer = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                local success, playerHeadText, identifier = lib.callback.await('abp_headFriend:RequestFriendship', false, targetPlayer)

                if success then
                    FriendAPI.Friends[targetPlayer] = {headtext = playerHeadText, source = targetPlayer, identifier = identifier}
                    if Config.UseKVPInsteadDatabase then
                        SetResourceKvp('friendships', json.encode(FriendAPI.Friends))
                    end
                end
            end,
            canInteract = function(entity, distance, coords, name)
                local targetPlayer = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                local distanceCheck = distance < 2 and true or false
                local isFriendOf = areFriends(targetPlayer) and true or false
                return distanceCheck and not isFriendOf
            end
        },
        {
            icon = "fas fa-hand",
            label = Translate("CANCEL_FRIENDSHIP"),
            onSelect = function(data)

                local alert = lib.alertDialog({
                    header = Translate("REQUEST_CANCEL_FRIENDSHIP"),
                    content = Translate("REQUEST_CANCEL_FRIENDSHIP_TEXT"),
                    centered = true,
                    cancel = true
                })

                if alert == "confirm" then
                    local targetPlayer = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                    local success = lib.callback.await('abp_headFriend:CancelFriendship', false, areFriends(targetPlayer).friendshipId, targetPlayer)

                    if success then
                        removeFriend(targetPlayer)

                        if Config.UseKVPInsteadDatabase then
                            SetResourceKvp('friendships', json.encode(FriendAPI.Friends))
                        end

                        lib.notify({
                            title = Translate("FRIENDSHIP"),
                            description = Translate("REQUEST_CANCEL_SUCCESS"),
                            type = "success"
                        })
                    end
                end

                
            end,
            canInteract = function(entity, distance, coords, name)
                if IsPedAPlayer(entity) then
                    local targetPlayer = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    local distanceCheck = distance < 2 and true or false
                    local isFriendOf = areFriends(targetPlayer) and true or false
                    return distanceCheck and isFriendOf
                end

                return false
            end
        },
    })
    
end



lib.callback.register('abp_headFriend:onRequestFriendship', function(fromPlayer, friendshipId)

    if Config.FriendAPI_UseConfirmDialogInsteadOfKeys then
        local alert = lib.alertDialog({
            header = 'Friendship Request',
            content = Translate("REQUEST_INVITATION", fromPlayer),
            centered = true,
            cancel = true
        })

        if alert == "confirm" then
            lib.notify({
                title = Translate("FRIENDSHIP"),
                description = Translate("REQUEST_ACCEPTED", fromPlayer),
                type = "success"
            })
            return true
        end
    else

        local timeout = Config.FriendAPI_RequestTimeout
        local status = nil
        CreateThread(function() 
            lib.showTextUI(Translate('REQUEST_PENDING_CONTROL_ACTION', fromPlayer), {
                position = "top-center",
                icon = "hand",
            })

            while timeout > 0 and status == nil do
                timeout -= 1
                Wait(1000)
            end

            lib.hideTextUI()
        end)

        CreateThread(function() 
            while timeout > 0 and status == nil do

                EnableControlAction(0, Config.FriendAPI_KeyToAccept, false)
                EnableControlAction(0, Config.FriendAPI_KeyToCancel, false)

                if IsDisabledControlJustPressed(0, Config.FriendAPI_KeyToAccept) then
                    status = true
                    break
                end

                if IsDisabledControlJustPressed(0, Config.FriendAPI_KeyToCancel) then
                    status = false
                    break
                end
                
                
                Wait(5)
            end

            EnableControlAction(0, Config.FriendAPI_KeyToAccept, true)
            EnableControlAction(0, Config.FriendAPI_KeyToCancel, true)

            if status == nil then
                lib.notify({
                    title = Translate("FRIENDSHIP"),
                    description = Translate("REQUEST_TIMEOUT_CANCELED"),
                    type = "success"
                })
            else
                if status then
                    lib.notify({
                        title = Translate("FRIENDSHIP"),
                        description = Translate("REQUEST_ACCEPTED", fromPlayer),
                        type = "success"
                    })

                    return true
                end
            end
        end)
    end

    return false
end)

CreateThread(function() 
    
    TriggerServerEvent('abp_headFriend::RegisterPlayer')

    while true do

        if FriendAPI.ShowHeadText then
            FriendAPI.NearPlayers = lib.getNearbyPlayers(GetEntityCoords(PlayerPedId()), Config.FriendAPI_HeadViewDistance, true)
        end

        if not Config.UseKVPInsteadDatabase then
            FriendAPI.Friends = lib.callback.await('abp_headFriend:RequestMyFriends', 200)
        end

        Wait(1300)
    end

end)

CreateThread(function() 

    while true do
        local timeout = 5

        if FriendAPI.ShowHeadText then
            if #FriendAPI.NearPlayers > 0 then
                for index, player in pairs(FriendAPI.NearPlayers) do
    
                    if IsPedAPlayer(player.ped) then
                        local targetPed = player.ped
    
                        if targetPed ~= PlayerPedId() then 
                            local playerServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                            local x2, y2, z2 = table.unpack(GetEntityCoords(targetPed, true))
    
                            local displayName = (Config.FriendAPI_HeadUnknownText and (Translate("UNKNOWN") .. " #" .. playerServerId) or "")
                            local areFriends = areFriends(playerServerId)

                            if areFriends then
                                displayName = areFriends.headtext
                            end
    
                            DrawText3D(x2, y2, z2 + 1.1, 1.5, displayName , 255, 255, 255)
                        end
                    end
                    
                end
            else
                timeout = 500
            end
        else
            timeout = 1000
        end

        Wait(timeout)
    end

end)


-- RegisterCommand('clearf', function() 
--     FriendAPI.Friends = {}
--     SetResourceKvp('friendships', json.encode(FriendAPI.Friends))
-- end)