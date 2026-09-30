Core = Core or {}
Core.Functions = Core.Functions or {}

-- [[ NATIVE PLAYER FUNCTIONS MODULE ]]
-- Master Directive v2.0 Compliant
-- This module acts as the API to manipulate live player data.
-- It prioritizes memory caching and state bags for instantaneous UI updates.

Core.Functions.GetPlayer = function(source)
    if not Core.Players[source] then return nil end
    local char = Core.Players[source]
    
    local Player = {}
    
    -- Structure the PlayerData for external script compatibility (like ps-adminmenu)
    Player.PlayerData = {
        source = source,
        citizenid = char.citizenid,
        name = char.firstname .. ' ' .. char.lastname,
        charinfo = {
            firstname = char.firstname,
            lastname = char.lastname,
            birthdate = char.dob,
            gender = char.gender,
            nationality = char.nationality
        },
        money = {
            cash = Player(source).state.cash or 0,
            bank = Player(source).state.bank or 0
        },
        job = char.job or { name = 'unemployed', grade = { level = 0 } },
        gang = char.gang or { name = 'none', grade = { level = 0 } },
        metadata = char.metadata or { hunger = 100, thirst = 100 }
    }

    Player.Functions = {}
    
    -- Natively integrated with ox_inventory and State Bags
    Player.Functions.AddMoney = function(moneyType, amount, reason)
        amount = tonumber(amount) or 0
        if amount <= 0 then return false end
        
        if moneyType == 'cash' then
            -- 1. Add physical item to ox_inventory
            exports.ox_inventory:AddItem(source, 'money', amount)
            
            -- 2. Update memory cache
            char.cash = (char.cash or 0) + amount
            
            -- 3. Push to State Bag (Immediately updates the React HUD without a network callback)
            Player(source).state:set('cash', char.cash, true)
            return true
            
        elseif moneyType == 'bank' then
            char.bank = (char.bank or 0) + amount
            Player(source).state:set('bank', char.bank, true)
            return true
        end
        
        return false
    end

    Player.Functions.RemoveMoney = function(moneyType, amount, reason)
        amount = tonumber(amount) or 0
        if amount <= 0 then return false end
        
        if moneyType == 'cash' then
            local currentCash = exports.ox_inventory:GetItemCount(source, 'money')
            if currentCash >= amount then
                -- 1. Remove physical item
                exports.ox_inventory:RemoveItem(source, 'money', amount)
                
                -- 2. Update cache and state bag
                char.cash = currentCash - amount
                Player(source).state:set('cash', char.cash, true)
                return true
            end
            return false
            
        elseif moneyType == 'bank' then
            if (char.bank or 0) >= amount then
                char.bank = char.bank - amount
                Player(source).state:set('bank', char.bank, true)
                return true
            end
            return false
        end
        
        return false
    end

    Player.Functions.SetJob = function(jobName, gradeLevel)
        -- Update memory cache
        char.job = { name = jobName, grade = { level = gradeLevel } }
        
        -- Update State Bag
        Player(source).state:set('job', char.job, true)
        
        return true
    end

    Player.Functions.SetMetaData = function(metaKey, metaValue)
        if not char.metadata then char.metadata = {} end
        
        -- Update memory cache
        char.metadata[metaKey] = metaValue
        
        -- Push generic metadata to State Bags (so HUD can natively catch hunger/thirst updates)
        Player(source).state:set(metaKey, metaValue, true)
        
        return true
    end
    
    return Player
end

Core.Functions.GetPlayers = function()
    local players = {}
    for src, _ in pairs(Core.Players) do 
        table.insert(players, Core.Functions.GetPlayer(src)) 
    end
    return players
end
