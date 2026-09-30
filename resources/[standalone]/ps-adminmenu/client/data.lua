local PedList = require "data.ped"

-- Returns a list of vehicles from Core.Shared.Vehicles
local function GetVehicles()
    local vehicles = {}

    for _, v in pairs(Core.Shared.Vehicles) do
        vehicles[#vehicles + 1] = { label = v.name, value = v.model }
    end

    return vehicles
end

-- Returns a list of items from ox_inventory or qb-inventory
local function GetItems()
    local items = {}

    if Config.Inventory == "ox_inventory" then
        local ItemsData = exports.ox_inventory:Items()

        for _, v in pairs(ItemsData) do
            items[#items + 1] = {
                label = v.label or v.name,
                value = v.name
            }
        end
    end

    if Config.Inventory == "qb-inventory" then
        local ItemsData = Core.Shared.Items

        for name, v in pairs(ItemsData) do
            items[#items + 1] = {
                label = v.label,
                value = name
            }
        end
    end

    return items
end

-- Returns a list of jobs from Core.Shared.Jobs
local function GetJobs()
    local jobs = {}

    for name, v in pairs(Core.Shared.Jobs) do
        local gradeDataList = {}

        for grade, gradeData in pairs(v.grades) do
            gradeDataList[#gradeDataList + 1] = { name = gradeData.name, grade = grade, isboss = gradeData.isboss }
        end

        jobs[#jobs + 1] = { label = v.label, value = name, grades = gradeDataList }
    end

    return jobs
end

-- Returns a list of gangs from Core.Shared.Gangs
local function GetGangs()
    local gangs = {}

    for name, v in pairs(Core.Shared.Gangs) do
        local gradeDataList = {}

        for grade, gradeData in pairs(v.grades) do
            gradeDataList[#gradeDataList + 1] = { name = gradeData.name, grade = grade, isboss = gradeData.isboss }
        end

        gangs[#gangs + 1] = { label = v.label, value = name, grades = gradeDataList }
    end

    return gangs
end

-- Returns a list of locations from Core.Shared.Loactions
local function GetLocations()
    local LocationList
    if GetResourceState('qb-core') == 'started' then
        LocationList = Core.Shared.Locations
    else
        LocationList = require "data.locations"
    end

    local locations = {}
    for name, v in pairs(LocationList) do
        locations[#locations + 1] = { label = name, value = v }
    end

    return locations
end

-- Sends data to the UI on resource start
function GetData()
    SendNUIMessage({
        action = "data",
        data = {
            vehicles = GetVehicles(),
            items = GetItems(),
            jobs = GetJobs(),
            gangs = GetGangs(),
            locations = GetLocations(),
            pedlist = PedList
        },
    })
end
