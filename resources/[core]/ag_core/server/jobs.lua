Core = Core or {}

-- [[ NATIVE JOBS SYSTEM: SERVER ]]
-- Master Directive v2.0 Compliant
-- Verifies all duty actions securely via server RAM before applying them.

RegisterNetEvent('ag_core:server:ToggleDuty', function()
    local src = source
    local player = Core.Functions.GetPlayer(src)
    
    -- Anti-exploit: Ensure the player actually exists in memory
    if not player then return end

    -- Extract job info natively from the secure server-side RAM cache
    local jobName = player.PlayerData.job.name
    local jobData = Core.Shared.Jobs[jobName]

    -- Anti-exploit: Verify the job exists in the config and the player isn't unemployed
    if not jobData or jobName == 'unemployed' then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Access Denied',
            description = 'You do not have authorization to clock in here.',
            type = 'error',
            icon = 'ban'
        })
        return
    end

    -- Determine new duty state
    -- Note: We directly access the raw cache via Core.Players to ensure data persists correctly
    local char = Core.Players[src]
    
    if not char.job then
        char.job = { name = 'unemployed', grade = { level = 0 }, onduty = false }
    end
    
    local newDutyState = not char.job.onduty
    char.job.onduty = newDutyState

    -- Push the generic boolean to State Bags (used for HUD/Quick Checks)
    Player(src).state:set('onDuty', newDutyState, true)
    
    -- Push the fully updated job table to State Bags (used for complex logic)
    Player(src).state:set('job', char.job, true)

    -- Native ox_lib notification to the client
    local message = newDutyState and ('You are now clocked in to ' .. jobData.label .. '.') or ('You are now clocked out.')
    local notifyType = newDutyState and 'success' or 'info'
    local notifyIcon = newDutyState and 'check-circle' or 'clipboard'

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Duty Update',
        description = message,
        type = notifyType,
        icon = notifyIcon
    })
end)
