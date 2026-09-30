local Core = exports['ag_core']:GetCoreObject()

--- Format ag_core player data into ox_inventory structure
---@diagnostic disable-next-line: duplicate-set-field
function server.setPlayerData(player)
    -- 'player' is the source ID passed from setPlayerInventory
    local src = player
    local char = Core.Functions.GetPlayer(src)
    
    if not char then return {} end
    
    return {
        source = src,
        name = char.PlayerData.name,
        groups = {
            [char.PlayerData.job.name] = char.PlayerData.job.grade.level,
            [char.PlayerData.gang.name] = char.PlayerData.gang.grade.level
        },
        sex = char.PlayerData.charinfo.gender,
        dateofbirth = char.PlayerData.charinfo.birthdate,
    }
end

--- Native Admin Verification Hook
--- ox_inventory calls this to verify if someone can run admin commands (/clearinventory, etc.)
---@diagnostic disable-next-line: duplicate-set-field
function server.hasGroup(player, group)
    local src = type(player) == 'table' and player.source or player
    return Core.Functions.HasPermission(src, group)
end

-- Hook into ag_core's character selection to boot the inventory
RegisterNetEvent('ag_core:server:SelectCharacter', function(citizenid)
    local src = source
    
    -- Wait 250ms for ag_core to fully cache the character into Core.Players memory
    SetTimeout(250, function()
        if Core.Functions.GetPlayer(src) then
            -- Tell ox_inventory to generate/load the inventory using the player's citizenid
            server.setPlayerInventory(src)
        end
    end)
end)

-- Ensure cleanup when a player drops (ox_inventory handles most of it, but good to be safe)
AddEventHandler('playerDropped', function()
    local src = source
    if server.playerDropped then
        server.playerDropped(src)
    end
end)
