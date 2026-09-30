Core = Core or {}
Core.Functions = {}
Core.Shared = { Vehicles = {}, Items = {}, Jobs = {}, Gangs = {} }
Config = { DefaultSpawn = { x = -269.4, y = -955.3, z = 31.2, w = 205.8 } }

function GetCoreObject()
    return Core
end
exports('GetCoreObject', GetCoreObject)

Core.Functions.GetPlayerData = function()
    return {
        citizenid = LocalPlayer.state.citizenid,
        money = { cash = LocalPlayer.state.cash or 0, bank = LocalPlayer.state.bank or 0 },
        job = { name = 'unemployed', grade = { level = 0 } },
        gang = { name = 'none', grade = { level = 0 } }
    }
end

Core.Functions.TriggerCallback = function(name, cb, ...)
    local args = {...}
    CreateThread(function()
        local result = lib.callback.await(name, false, table.unpack(args))
        if cb then
            if type(result) == 'table' then cb(table.unpack(result)) else cb(result) end
        end
    end)
end

-- Wait for player to be fully loaded into the game engine
CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(100)
    end
    
    -- Initialize State Bags default
    LocalPlayer.state:set('isLoggedIn', false, false)
    
    -- Tell server we are ready
    TriggerServerEvent('ag_core:server:PlayerJoined')
end)

-- Show Character Selection
RegisterNetEvent('ag_core:client:ShowCharacterSelect', function(characters)
    ShutdownLoadingScreenNui()
    ShutdownLoadingScreen()
    Wait(500)
    DoScreenFadeOut(500)
    Wait(1000)
    
    SetNuiFocus(true, true)
    
    if not characters or #characters == 0 then
        TriggerEvent('ag_ui:client:SendNUIMessage', {
            action = "openCharacterCreate"
        })
    else
        TriggerEvent('ag_ui:client:SendNUIMessage', {
            action = "openCharacterSelect",
            data = characters
        })
    end
end)



RegisterNetEvent('ag_core:client:SpawnCharacter', function(charData)
    -- Disable NUI focus once we spawn
    SetNuiFocus(false, false)
    
    local pos = charData.position and json.decode(charData.position) or Config.DefaultSpawn
    
    local model = GetHashKey("mp_m_freemode_01")
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)
    
    SetEntityCoords(PlayerPedId(), pos.x, pos.y, pos.z, false, false, false, true)
    SetEntityHeading(PlayerPedId(), pos.w or 0.0)
    
    Wait(500)
    DoScreenFadeIn(1000)
    
    print("Spawned as: " .. charData.firstname .. " " .. charData.lastname)
end)

-- Example of highly optimized generic loop avoiding Wait(0)
CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            local sleep = 1000 
            
            -- We avoid global distance loops when possible and use ox_target.
            -- This is here just as an example of dynamic thread sleeping.
            
            Wait(sleep)
        else
            Wait(2000)
        end
    end
end)
