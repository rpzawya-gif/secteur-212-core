Core = Core or {}
Core.DB = {}

-- Retrieve or create a player's account based on license2
function Core.DB.GetOrCreateAccount(identifiers)
    local license2 = identifiers['license2']
    local license = identifiers['license']
    local discord = identifiers['discord']

    if not license2 then license2 = license end
    if not license2 then return nil end

    local account = MySQL.query.await('SELECT * FROM accounts WHERE license2 = ?', { license2 })
    
    if account and #account > 0 then
        return account[1]
    else
        MySQL.insert.await('INSERT IGNORE INTO accounts (license2, license, discord) VALUES (?, ?, ?)', {
            license2, license, discord
        })
        return {
            license2 = license2,
            license = license,
            discord = discord,
            group = 'user',
            banned = false
        }
    end
end

-- Get all characters for an account (Character Selection NUI)
function Core.DB.GetAccountCharacters(license2)
    local chars = MySQL.query.await('SELECT * FROM characters WHERE license2 = ?', { license2 })
    
    -- Ensure JSONs are properly parsed before sending to client NUI
    for i = 1, #chars do
        if type(chars[i].job) == 'string' then chars[i].job = json.decode(chars[i].job) end
        if type(chars[i].gang) == 'string' then chars[i].gang = json.decode(chars[i].gang) end
        if type(chars[i].metadata) == 'string' then chars[i].metadata = json.decode(chars[i].metadata) end
    end
    
    return chars
end

-- Load Character (Called when player selects a specific character)
function Core.DB.LoadCharacter(source, citizenid)
    local character = MySQL.query.await('SELECT * FROM characters WHERE citizenid = ?', { citizenid })
    
    if character and #character > 0 then
        local charData = character[1]
        
        -- Asynchronously parse JSON metadata into native Lua tables
        if type(charData.job) == 'string' then charData.job = json.decode(charData.job) end
        if type(charData.gang) == 'string' then charData.gang = json.decode(charData.gang) end
        if type(charData.metadata) == 'string' then charData.metadata = json.decode(charData.metadata) end
        
        -- Inject exactly into RAM cache
        Core.Players[source] = charData
        return charData
    end
    
    return nil
end

-- Save Character (Called asynchronously on player drop or routine save)
function Core.DB.SaveCharacter(source)
    if not Core.Players[source] then return end
    
    local char = Core.Players[source]
    local ped = GetPlayerPed(source)
    local position = {x = 0, y = 0, z = 0}
    
    if ped and ped ~= 0 then
        local coords = GetEntityCoords(ped)
        position = {x = coords.x, y = coords.y, z = coords.z}
    end

    MySQL.update.await('UPDATE characters SET cash = ?, bank = ?, position = ?, job = ?, gang = ?, metadata = ? WHERE citizenid = ?', {
        char.cash or 0,
        char.bank or 0,
        json.encode(position),
        json.encode(char.job or { name = 'unemployed', grade = { level = 0 } }),
        json.encode(char.gang or { name = 'none', grade = { level = 0 } }),
        json.encode(char.metadata or { hunger = 100, thirst = 100 }),
        char.citizenid
    })
end
