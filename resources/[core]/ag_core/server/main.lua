Core = Core or {}
Core.Players = {} -- Memory Cache for live players
Core.Functions = {}
Core.Shared = { Vehicles = {}, Items = {}, Jobs = {}, Gangs = {} }

function GetCoreObject()
    return Core
end
exports('GetCoreObject', GetCoreObject)

Core.Functions.CreateCallback = function(name, cb)
    lib.callback.register(name, function(source, ...)
        local p = promise.new()
        cb(source, function(...) p:resolve({...}) end, ...)
        return table.unpack(Citizen.Await(p))
    end)
end

Core.Functions.GetIdentifier = function(source, idtype)
    local idtype = idtype or 'license'
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.find(id, idtype .. ":") then return id end
    end
    return nil
end

RegisterNetEvent('QBCore:CallCommand', function(...) end)
RegisterNetEvent('QBCore:ToggleDuty', function(...) end)

-- Utility to extract identifiers
local function ExtractIdentifiers(source)
    local identifiers = {}
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.find(id, "license2:") then
            identifiers['license2'] = id
        elseif string.find(id, "license:") then
            identifiers['license'] = id
        elseif string.find(id, "discord:") then
            identifiers['discord'] = id
        end
    end
    return identifiers
end

-- Player Connecting Event
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    deferrals.defer()
    Wait(0)
    
    deferrals.update("Checking identifiers...")
    
    local identifiers = ExtractIdentifiers(src)
    if not identifiers['license2'] and not identifiers['license'] then
        deferrals.done("You must have a valid Rockstar License to join Secteur 212.")
        return
    end
    
    deferrals.update("Loading account data...")
    
    -- Load from DB asynchronously
    CreateThread(function()
        local account = Core.DB.GetOrCreateAccount(identifiers)
        
        if not account then
            deferrals.done("Failed to load account data. Please try again.")
            return
        end
        
        if account.banned then
            deferrals.done("You are permanently banned from Secteur 212.")
            return
        end
        
        deferrals.done()
    end)
end)

-- Event when player fully joins and spawns
RegisterNetEvent('ag_core:server:PlayerJoined', function()
    local src = source
    local identifiers = ExtractIdentifiers(src)
    local license2 = identifiers['license2'] or identifiers['license']
    
    -- Fetch characters for this account
    local characters = Core.DB.GetAccountCharacters(license2)
    
    -- Move player to routing bucket while in character selection
    SetPlayerRoutingBucket(src, src)
    
    -- Send data to client to display Character Selection NUI
    TriggerClientEvent('ag_core:client:ShowCharacterSelect', src, characters)
end)

-- Handle Character Selection
RegisterNetEvent('ag_core:server:SelectCharacter', function(citizenid)
    local src = source
    local identifiers = ExtractIdentifiers(src)
    local license2 = identifiers['license2'] or identifiers['license']
    
    -- Use the native DB module to load and parse the character JSONs directly to Core.Players cache
    local charData = Core.DB.LoadCharacter(src, citizenid)
    
    if charData and charData.license2 == license2 then
        -- Setup State Bags for Client optimization
        Player(src).state:set('citizenid', charData.citizenid, true)
        Player(src).state:set('cash', charData.cash, true)
        Player(src).state:set('bank', charData.bank, true)
        
        -- Push complex tables directly to state bags
        Player(src).state:set('job', charData.job, true)
        Player(src).state:set('gang', charData.gang, true)
        if charData.metadata then
            Player(src).state:set('hunger', charData.metadata.hunger or 100, true)
            Player(src).state:set('thirst', charData.metadata.thirst or 100, true)
        end
        
        Player(src).state:set('isLoggedIn', true, true)
        
        -- Set Routing Bucket back to normal (0)
        SetPlayerRoutingBucket(src, 0)
        
        TriggerClientEvent('ag_core:client:SpawnCharacter', src, charData)
    else
        DropPlayer(src, "Exploit Detected: Attempted to load an invalid character.")
    end
end)

local function GenerateCitizenId()
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local length = 8
    local id = ''
    for i = 1, length do
        local rand = math.random(1, #chars)
        id = id .. string.sub(chars, rand, rand)
    end
    return id
end

RegisterNetEvent('ag_core:server:CreateCharacter', function(data)
    local src = source
    local identifiers = ExtractIdentifiers(src)
    local license2 = identifiers['license2'] or identifiers['license']
    
    if not license2 then return end

    local citizenid = GenerateCitizenId()
    
    -- In production, validate data.firstname, etc. to prevent exploits.
    MySQL.insert.await('INSERT INTO characters (citizenid, license2, firstname, lastname, dob, gender, nationality) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        citizenid, license2, data.firstname, data.lastname, data.dob, data.gender, data.nationality
    })
    
    -- Reload character select
    local characters = Core.DB.GetAccountCharacters(license2)
    TriggerClientEvent('ag_core:client:ShowCharacterSelect', src, characters)
end)

-- Cleanup on disconnect
AddEventHandler('playerDropped', function(reason)
    local src = source
    if Core.Players[src] then
        -- Trigger optimized async DB save
        Core.DB.SaveCharacter(src)
        
        Core.Players[src] = nil
    end
end)
