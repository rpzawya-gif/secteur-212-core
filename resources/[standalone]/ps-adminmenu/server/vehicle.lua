-- Admin Car
RegisterNetEvent('ps-adminmenu:server:SaveCar', function(data, mods, vehicle, _, plate)
    local src = source
    
    if not data or not CheckPerms(src, data.perms) then
        TriggerClientEvent('ox_lib:notify', src, { type = "error", description = locale("no_perms") })
        return
    end
    
    local Player = Core.Functions.GetPlayer(src)
    local result = MySQL.query.await('SELECT plate FROM player_vehicles WHERE plate = ?', { plate })

    if result[1] == nil then
        MySQL.insert(
        'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)',
            {
                Player.PlayerData.license,
                Player.PlayerData.citizenid,
                vehicle.model,
                vehicle.hash,
                json.encode(mods),
                plate,
                0
            })
        TriggerClientEvent('QBCore:Notify', src, locale("veh_owner"), 'success', 5000)
    else
        TriggerClientEvent('QBCore:Notify', src, locale("u_veh_owner"), 'error', 3000)
    end
end)

-- Give Car
RegisterNetEvent("ps-adminmenu:server:givecar", function(data, selectedData)
    local src = source

    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then
        TriggerClientEvent('ox_lib:notify', src, { type = "error", description = locale("no_perms") })
        return
    end

    local vehmodel = selectedData['Vehicle'].value
    local vehicleData = lib.callback.await("ps-adminmenu:client:getvehData", src, vehmodel)

    if not next(vehicleData) then
        return
    end

    local tsrc = selectedData['Player'].value
    local plate = selectedData['Plate (Optional)'] and selectedData['Plate (Optional)'].value or vehicleData.plate
    local garage = selectedData['Garage (Optional)'] and selectedData['Garage (Optional)'].value or Config.DefaultGarage
    local Player = Core.Functions.GetPlayer(tsrc)

    if plate and #plate < 1 then
        plate = vehicleData.plate
    end

    if garage and #garage < 1 then
        garage = Config.DefaultGarage
    end

    if plate:len() > 8 then
        TriggerClientEvent('ox_lib:notify', src, { type = "error", description = locale("plate_max") })
        return
    end

    if not Player then
        TriggerClientEvent('ox_lib:notify', src, { type = "error", description = locale("not_online") })
        return
    end

    if CheckAlreadyPlate(plate) then
        TriggerClientEvent('ox_lib:notify', src, { type = plate:upper(), description = locale("givecar.error.plates_alreadyused" }), "error", 5000)
        return
    end

    MySQL.insert(
    'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        {
            Player.PlayerData.license,
            Player.PlayerData.citizenid,
            vehmodel,
            joaat(vehmodel),
            json.encode(vehicleData),
            plate,
            garage,
            1
        })

    TriggerClientEvent('ox_lib:notify', src, { type = Core.Shared.Vehicles[vehmodel].name, description = locale("givecar.success.source" }):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)), "success", 5000)
    TriggerClientEvent('ox_lib:notify', Player.PlayerData.source, { type = plate:upper(), description = locale("givecar.success.target" }), "success",
        5000)
end)

-- Give Car
RegisterNetEvent("ps-adminmenu:server:SetVehicleState", function(data, selectedData)
    local src = source

    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then
        TriggerClientEvent('ox_lib:notify', src, { type = "error", description = locale("no_perms") })
        return
    end

    local plate = string.upper(selectedData['Plate'].value)
    local state = tonumber(selectedData['State'].value)

    if plate:len() > 8 then
        TriggerClientEvent('ox_lib:notify', src, { type = "error", description = locale("plate_max") })
        return
    end

    if not CheckAlreadyPlate(plate) then
        TriggerClientEvent('ox_lib:notify', src, { type = "error", description = locale("plate_doesnt_exist") })
        return
    end

    MySQL.update('UPDATE player_vehicles SET state = ?, depotprice = ? WHERE plate = ?', { state, 0, plate })

    TriggerClientEvent('ox_lib:notify', src, { type = "success", description = locale("state_changed") })
end)

-- Change Plate
local function tableExists(tableName)
    local result = MySQL.query.await('SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = ?', { tableName })
    return result and result[1] ~= nil
end

RegisterNetEvent('ps-adminmenu:server:ChangePlate', function(newPlate, currentPlate)
    local newPlate = newPlate:upper()

    if Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:UpdateVehicle(currentPlate, newPlate)
    end

    MySQL.Sync.execute('UPDATE player_vehicles SET plate = ? WHERE plate = ?', { newPlate, currentPlate })
    if tableExists('trunkitems') then
        MySQL.Sync.execute('UPDATE trunkitems SET plate = ? WHERE plate = ?', { newPlate, currentPlate })
    end
    if tableExists('gloveboxitems') then
        MySQL.Sync.execute('UPDATE gloveboxitems SET plate = ? WHERE plate = ?', { newPlate, currentPlate })
    end
end)

lib.callback.register('ps-adminmenu:server:GetVehicleByPlate', function(source, plate)
    local result = MySQL.query.await('SELECT vehicle FROM player_vehicles WHERE plate = ?', { plate })
    local veh = result[1] and result[1].vehicle or {}
    return veh
end)

-- Fix Vehicle for player
RegisterNetEvent('ps-adminmenu:server:FixVehFor', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local src = source
    local playerId = selectedData['Player'].value
    local Player = Core.Functions.GetPlayer(tonumber(playerId))
    if Player then
        local name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
        TriggerClientEvent('iens:repaira', Player.PlayerData.source)
        TriggerClientEvent('vehiclemod:client:fixEverything', Player.PlayerData.source)
        TriggerClientEvent('ox_lib:notify', src, { type = name, description = locale("veh_fixed" }), 'success', 7500)
    else
        TriggerClientEvent('QBCore:Notify', src, locale("not_online"), "error")
    end
end)
