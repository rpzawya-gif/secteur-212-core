-- Freeze Player
local frozen = false
RegisterNetEvent('ps-adminmenu:server:FreezePlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local src = source

    local target = selectedData["Player"].value

    local ped = GetPlayerPed(target)
    local Player = Core.Functions.GetPlayer(target)

    if not frozen then
        frozen = true
        FreezeEntityPosition(ped, true)
        TriggerClientEvent('ox_lib:notify', src, { type = Player.PlayerData.charinfo.firstname ..
                " " .. Player.PlayerData.charinfo.lastname .. " | " .. Player.PlayerData.citizenid, description = locale("Frozen" }), 'Success', 7500)
    else
        frozen = false
        FreezeEntityPosition(ped, false)
        TriggerClientEvent('ox_lib:notify', src, { type = Player.PlayerData.charinfo.firstname ..
                " " .. Player.PlayerData.charinfo.lastname .. " | " .. Player.PlayerData.citizenid, description = locale("deFrozen" }), 'Success', 7500)
    end
    if Player == nil then return TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale("not_online") }) end
end)

-- Drunk Player
RegisterNetEvent('ps-adminmenu:server:DrunkPlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local target = selectedData["Player"].value
    local targetPed = GetPlayerPed(target)
    local Player = Core.Functions.GetPlayer(target)

    if not Player then
        return TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale("not_online") })
    end

    TriggerClientEvent('ps-adminmenu:client:InitiateDrunkEffect', target)
    TriggerClientEvent('ox_lib:notify', src, { type = Player.PlayerData.charinfo.firstname ..
            " " .. Player.PlayerData.charinfo.lastname .. " | " .. Player.PlayerData.citizenid, description = locale("playerdrunk" }), 'Success', 7500)
end)
