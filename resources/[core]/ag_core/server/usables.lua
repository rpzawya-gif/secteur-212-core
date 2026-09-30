Core = Core or {}

-- [[ NATIVE USABLE ITEMS EXPORT ]]
-- Master Directive v2.0 Compliant
-- Provides a direct server export for ox_inventory to execute upon item consumption.

-- Centralized configuration for consumable replenish rates
local Consumables = {
    ['water_bottle'] = { type = 'thirst', amount = 35 },
    ['burger']       = { type = 'hunger', amount = 40 },
    ['cola']         = { type = 'thirst', amount = 20 },
    ['sandwich']     = { type = 'hunger', amount = 30 }
}

exports('ConsumeItem', function(event, item, inventory, slot, data)
    -- ox_inventory triggers this export twice: 'usingItem' (before progress bar) and 'usedItem' (after successful use)
    -- We only want to apply the metabolic changes if the player successfully finishes consuming the item.
    if event ~= 'usedItem' then return end

    local src = inventory.id
    local player = Core.Functions.GetPlayer(src)
    
    if not player then return end

    local consumeData = Consumables[item.name]
    
    if consumeData then
        -- Pull current metadata natively from RAM Cache
        local currentMeta = player.PlayerData.metadata
        local statType = consumeData.type
        local currentAmount = currentMeta[statType] or 0
        
        -- Calculate new value and cap it at 100
        local newAmount = currentAmount + consumeData.amount
        if newAmount > 100 then 
            newAmount = 100 
        end
        
        -- Natively push updated value. 
        -- This instantly updates the State Bag, causing the React HUD to reflect the change visually.
        player.Functions.SetMetaData(statType, newAmount)
    end
end)
