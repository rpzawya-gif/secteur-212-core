local Core = exports['ag_core']:GetCoreObject()

-- Listen natively to the ag_core State Bag to trigger inventory initialization
AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(GetPlayerServerId(PlayerId())), function(bagName, key, value)
    if value then
        local player = Core.Functions.GetPlayerData()
        
        -- Define player identity and groups for ox_inventory dynamically
        client.setPlayerData('citizenid', player.citizenid)
        
        -- Set groups for police/gang restrictions (defaults to unemployed)
        client.setPlayerData('groups', {
            [player.job.name] = player.job.grade.level,
            [player.gang.name] = player.gang.grade.level
        })
        
        -- Tell ox_inventory to boot the inventory UI and logic for this client
        client.onPlayerLoaded()
    else
        client.onLogout()
    end
end)

-- Native hook to handle death events in ox_inventory (to drop weapons/items if configured)
AddEventHandler('gameEventTriggered', function(event, data)
    if event ~= 'CEventNetworkEntityDamage' then return end
    local victim, attacker, victimDied, weapon = data[1], data[2], data[4], data[7]
    if not IsPedAPlayer(victim) or not victimDied or NetworkGetPlayerIndexFromPed(victim) ~= PlayerId() then return end
    
    -- Notifies ox_inventory the player is dead
    local Weapon = require 'modules.weapon.client'
    Weapon.Disarm()
    client.player:setr('invBusy', true)
end)

-- Ensure inventory resets if the player respawns
RegisterNetEvent('ag_core:client:PlayerRevived', function()
    client.player:setr('invBusy', false)
end)
