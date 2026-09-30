local isHudVisible = false
local lastHealth = -1
local lastArmor = -1

-- Wait until logged in to show HUD
AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(GetPlayerServerId(PlayerId())), function(bagName, key, value)
    if value then
        isHudVisible = true
        SendNUIMessage({
            action = 'updateHUD',
            payload = {
                cash = LocalPlayer.state.cash or 0,
                bank = LocalPlayer.state.bank or 0
            }
        })
    else
        isHudVisible = false
        SendNUIMessage({ action = 'hideHUD' })
    end
end)

-- Listen for Cash/Bank changes and NATIVELY push to NUI
AddStateBagChangeHandler('cash', ('player:%s'):format(GetPlayerServerId(PlayerId())), function(bagName, key, value)
    if isHudVisible then
        SendNUIMessage({ action = 'updateHUD', payload = { cash = value } })
    end
end)

AddStateBagChangeHandler('bank', ('player:%s'):format(GetPlayerServerId(PlayerId())), function(bagName, key, value)
    if isHudVisible then
        SendNUIMessage({ action = 'updateHUD', payload = { bank = value } })
    end
end)

-- Optimized Loop for Health & Armor (Runs every 250ms instead of 0ms)
CreateThread(function()
    while true do
        if isHudVisible then
            local ped = PlayerPedId()
            -- Health in GTA is usually 100-200. We normalize it to 0-100.
            local health = GetEntityHealth(ped) - 100
            if health < 0 then health = 0 end
            if health > 100 then health = 100 end
            
            local armor = GetPedArmour(ped)
            
            if health ~= lastHealth or armor ~= lastArmor then
                lastHealth = health
                lastArmor = armor
                
                SendNUIMessage({
                    action = 'updateHUD',
                    payload = {
                        health = health,
                        armor = armor
                    }
                })
            end
            
            Wait(250)
        else
            Wait(2000)
        end
    end
end)
