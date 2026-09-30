-- Ban Player
RegisterNetEvent('ps-adminmenu:server:BanPlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local player = tonumber(selectedData["Player"] and selectedData["Player"].value)
    local reason = (selectedData["Reason"] and selectedData["Reason"].value) or ""
    local time = tonumber(selectedData["Duration"] and selectedData["Duration"].value)

    if not player then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale("not_online") })
        return
    end

    if not time then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale("empty_input") })
        return
    end

    local banTime = tonumber(os.time() + time)
    local expire = banTime

    if time == 2147483647 or banTime > 2147483647 then
        expire = 2147483647
    end

    local timeTable = os.date('*t', banTime)

    local insertId = MySQL.insert.await(
        'INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)',
        {
            GetPlayerName(player),
            Core.Functions.GetIdentifier(player, 'license'),
            Core.Functions.GetIdentifier(player, 'discord'),
            Core.Functions.GetIdentifier(player, 'ip'),
            reason,
            expire,
            GetPlayerName(source)
        }
    )

    if not insertId then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = "Ban failed: database insert error (check oxmysql and bans table)." })
        return
    end

    if time == 2147483647 then
        DropPlayer(player, locale("banned") .. '\n' .. locale("reason") .. reason .. locale("ban_perm"))
    else
        DropPlayer(player,
            locale("banned") ..
            '\n' ..
            locale("reason") ..
            reason ..
            '\n' ..
            locale("ban_expires") ..
            timeTable['day'] ..
            '/' .. timeTable['month'] .. '/' .. timeTable['year'] .. ' ' .. timeTable['hour'] .. ':' .. timeTable['min'])
    end

    if source and GetPlayerName(source) then
        Core.Functions.Notify(source, locale("playerbanned", player, banTime, reason), 'success', 7500)
    end
end)

-- Warn Player
RegisterNetEvent('ps-adminmenu:server:WarnPlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local targetId = selectedData["Player"].value
    local target = Core.Functions.GetPlayer(targetId)
    local reason = selectedData["Reason"].value
    local sender = Core.Functions.GetPlayer(source)
    local warnId = 'WARN-' .. math.random(1111, 9999)
    if target ~= nil then
        TriggerClientEvent('ox_lib:notify', target.PlayerData.source, { type = for: " .. locale("reason", description = locale("warned") .. " }) .. ": " .. reason, 'inform', 10000)
        TriggerClientEvent('ox_lib:notify', source, { type = for: " .. reason, description = locale("warngiven") .. GetPlayerName(target.PlayerData.source) .. " })
        MySQL.insert('INSERT INTO player_warns (senderIdentifier, targetIdentifier, reason, warnId) VALUES (?, ?, ?, ?)',
            {
                sender.PlayerData.license,
                target.PlayerData.license,
                reason,
                warnId
            })
    else
        TriggerClientEvent('QBCore:Notify', source, locale("not_online"), 'error')
    end
end)

RegisterNetEvent('ps-adminmenu:server:KickPlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local src = source
    local target = Core.Functions.GetPlayer(selectedData["Player"].value)
    local reason = selectedData["Reason"].value

    if not target then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale("not_online") })
        return
    end

    DropPlayer(target.PlayerData.source, locale("kicked") .. '\n' .. locale("reason") .. reason)
end)

-- Revive Player
RegisterNetEvent('ps-adminmenu:server:Revive', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local player = selectedData["Player"].value
    if GetResourceState('qbx_medical') == 'started' then
        exports.qbx_medical:Revive(player)
    else
        TriggerClientEvent('hospital:client:Revive', player)
    end
end)

-- Revive All
RegisterNetEvent('ps-adminmenu:server:ReviveAll', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    if GetResourceState('qbx_medical') == 'started' then
        exports.qbx_medical:Revive(-1)
    else
        TriggerClientEvent('hospital:client:Revive', -1)
    end
end)

-- Revive Radius
RegisterNetEvent('ps-adminmenu:server:ReviveRadius', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local ped = GetPlayerPed(src)
    local pos = GetEntityCoords(ped)
    local players = Core.Functions.GetPlayers()

    for k, v in pairs(players) do
        local target = GetPlayerPed(v)
        local targetPos = GetEntityCoords(target)
        local dist = #(pos - targetPos)

        if dist < 15.0 then
            if GetResourceState('qbx_medical') == 'started' then
                exports.qbx_medical:Revive(v)
            else
                TriggerClientEvent('hospital:client:Revive', v)
            end
        end
    end
end)

-- Set RoutingBucket
RegisterNetEvent('ps-adminmenu:server:SetBucket', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local player = selectedData["Player"].value
    local bucket = selectedData["Bucket"].value
    local currentBucket = GetPlayerRoutingBucket(player)

    if bucket == currentBucket then
        return TriggerClientEvent('ox_lib:notify', src, { type = player, description = locale("target_same_bucket" }), 'error', 7500)
    end

    SetPlayerRoutingBucket(player, bucket)
    TriggerClientEvent('ox_lib:notify', src, { type = player, description = locale("bucket_set_for_target" }), 'success', 7500)
end)

-- Get RoutingBucket
RegisterNetEvent('ps-adminmenu:server:GetBucket', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local player = selectedData["Player"].value
    local currentBucket = GetPlayerRoutingBucket(player)

    TriggerClientEvent('ox_lib:notify', src, { type = player, description = locale("bucket_get" }), 'success', 7500)
end)

-- Give Money
RegisterNetEvent('ps-adminmenu:server:GiveMoney', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local target, amount, moneyType = selectedData["Player"].value, selectedData["Amount"].value,
        selectedData["Type"].value
    local Player = Core.Functions.GetPlayer(tonumber(target))

    if Player == nil then
        return TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale("not_online") })
    end

    Player.Functions.AddMoney(tostring(moneyType), tonumber(amount))
    TriggerClientEvent('ox_lib:notify', src, { type = tonumber(amount), description = locale((moneyType == "crypto" and "give_money_crypto" or "give_money") }), "success")
end)

-- Give Money to all
RegisterNetEvent('ps-adminmenu:server:GiveMoneyAll', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local amount, moneyType = selectedData["Amount"].value, selectedData["Type"].value
    local players = Core.Functions.GetPlayers()

    for _, v in pairs(players) do
        local Player = Core.Functions.GetPlayer(tonumber(v))
        Player.Functions.AddMoney(tostring(moneyType), tonumber(amount))
        TriggerClientEvent('ox_lib:notify', src, { type = tonumber(amount)), description = locale((moneyType == "crypto" and "give_money_all_crypto" or "give_money_all") })
    end
end)

-- Take Money
RegisterNetEvent('ps-adminmenu:server:TakeMoney', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local target, amount, moneyType = selectedData["Player"].value, selectedData["Amount"].value,
        selectedData["Type"].value
    local Player = Core.Functions.GetPlayer(tonumber(target))

    if Player == nil then
        return TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale("not_online") })
    end

    if Player.PlayerData.money[moneyType] >= tonumber(amount) then
        Player.Functions.RemoveMoney(moneyType, tonumber(amount), "state-fees")
    else
        TriggerClientEvent('ox_lib:notify', src, { type = "primary")
    end

    Core.Functions.Notify(src, description = locale("not_enough_money") }), tonumber(amount) .. "$",
            Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname), "success")
end)

-- Blackout
local Blackout = false
RegisterNetEvent('ps-adminmenu:server:ToggleBlackout', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    Blackout = not Blackout

    local src = source

    if Blackout then
        TriggerClientEvent('QBCore:Notify', src, locale("blackout", "enabled"), 'primary')
        while Blackout do
            Wait(0)
            exports["qb-weathersync"]:setBlackout(true)
        end
        exports["qb-weathersync"]:setBlackout(false)
        TriggerClientEvent('QBCore:Notify', src, locale("blackout", "disabled"), 'primary')
    end
end)

-- Toggle Cuffs
RegisterNetEvent('ps-adminmenu:server:CuffPlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local target = selectedData["Player"].value

    TriggerClientEvent('ps-adminmenu:client:ToggleCuffs', target)
    TriggerClientEvent('ox_lib:notify', source, { type = 'success')
end, description = locale("toggled_cuffs") })

-- Give Clothing Menu
RegisterNetEvent('ps-adminmenu:server:ClothingMenu', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local target = tonumber(selectedData["Player"].value)

    if target == nil then
        return TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale("not_online") })
    end

    if target == src then
        TriggerClientEvent("ps-adminmenu:client:CloseUI", src)
    end

    TriggerClientEvent('qb-clothing:client:openMenu', target)
end)

-- Set Ped
RegisterNetEvent("ps-adminmenu:server:setPed", function(data, selectedData)
    local src = source
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then
        TriggerClientEvent('ox_lib:notify', src, { type = "error", description = locale("no_perms") })
        return
    end

    local ped = selectedData["Ped Models"].label
    local tsrc = selectedData["Player"].value
    local Player = Core.Functions.GetPlayer(tsrc)

    if not Player then
        Core.Functions.Notify(locale("not_online"), "error", 5000)
        return
    end

    TriggerClientEvent("ps-adminmenu:client:setPed", Player.PlayerData.source, ped)
end)
