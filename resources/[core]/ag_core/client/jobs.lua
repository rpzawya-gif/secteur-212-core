local Core = exports['ag_core']:GetCoreObject()

-- [[ NATIVE JOBS SYSTEM: CLIENT ]]
-- Master Directive v2.0 Compliant
-- Uses ox_target natively to eliminate client CPU loops.

CreateThread(function()
    
    -- [[ 1. Police Duty Target ]]
    exports.ox_target:addBoxZone({
        coords = vec3(441.8, -981.8, 30.7), -- Placeholder: Update to Moroccan MLO coords
        size = vec3(1.0, 1.0, 2.0),
        rotation = 0.0,
        debug = false,
        options = {
            {
                name = 'duty_police',
                event = 'ag_core:client:RequestDutyToggle',
                icon = 'fas fa-clipboard-list',
                label = 'Clock In / Out (Police)',
                -- Natively checks RAM via State Bag, no server callback required to render
                canInteract = function(entity, distance, coords, name, bone)
                    local job = LocalPlayer.state.job
                    return job and job.name == 'police'
                end
            }
        }
    })

    -- [[ 2. Ambulance Duty Target ]]
    exports.ox_target:addBoxZone({
        coords = vec3(298.5, -598.5, 43.2), -- Placeholder: Update to Moroccan MLO coords
        size = vec3(1.0, 1.0, 2.0),
        rotation = 0.0,
        debug = false,
        options = {
            {
                name = 'duty_ambulance',
                event = 'ag_core:client:RequestDutyToggle',
                icon = 'fas fa-clipboard-list',
                label = 'Clock In / Out (EMS)',
                canInteract = function(entity, distance, coords, name, bone)
                    local job = LocalPlayer.state.job
                    return job and job.name == 'ambulance'
                end
            }
        }
    })

    -- [[ 3. Mechanic Duty Target ]]
    exports.ox_target:addBoxZone({
        coords = vec3(-347.2, -133.3, 39.0), -- Placeholder: Update to Moroccan MLO coords
        size = vec3(1.0, 1.0, 2.0),
        rotation = 0.0,
        debug = false,
        options = {
            {
                name = 'duty_mechanic',
                event = 'ag_core:client:RequestDutyToggle',
                icon = 'fas fa-clipboard-list',
                label = 'Clock In / Out (Mechanic)',
                canInteract = function(entity, distance, coords, name, bone)
                    local job = LocalPlayer.state.job
                    return job and job.name == 'mechanic'
                end
            }
        }
    })

end)

-- Securely route the local click to the server-side validator
RegisterNetEvent('ag_core:client:RequestDutyToggle', function()
    TriggerServerEvent('ag_core:server:ToggleDuty')
end)
