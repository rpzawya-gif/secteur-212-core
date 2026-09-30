Core = Core or {}

-- [[ NATIVE AUTOMATED PAYCHECK SYSTEM ]]
-- Master Directive v2.0 Compliant
-- Completely server-authoritative. The client cannot request, trigger, or exploit a paycheck.

-- Configuration
local PAYCHECK_INTERVAL = 900000 -- 15 Minutes (in milliseconds)

CreateThread(function()
    while true do
        Wait(PAYCHECK_INTERVAL)
        
        -- Pull all active players natively from the RAM Cache
        local players = Core.Functions.GetPlayers()
        
        for _, player in pairs(players) do
            if player and player.PlayerData then
                local src = player.PlayerData.source
                local jobName = player.PlayerData.job.name
                local jobLevel = tostring(player.PlayerData.job.grade.level)
                local isOnDuty = player.PlayerData.job.onduty
                
                local jobConfig = Core.Shared.Jobs[jobName]
                
                if jobConfig then
                    local gradeConfig = jobConfig.grades[jobLevel]
                    
                    if gradeConfig then
                        local paymentAmount = gradeConfig.payment or 0
                        local shouldPay = false
                        
                        -- Rule 1: Civilian Jobs (defaultDuty = true) get paid unconditionally
                        if jobConfig.defaultDuty == true then
                            shouldPay = true
                        
                        -- Rule 2: Whitelisted Jobs (defaultDuty = false) MUST be clocked in to receive the paycheck
                        elseif jobConfig.defaultDuty == false and isOnDuty == true then
                            shouldPay = true
                        
                        -- Rule 3: Configurable Off-Duty Pay (if enabled in shared/jobs.lua)
                        elseif jobConfig.offDutyPay == true and isOnDuty == false then
                            shouldPay = true
                        end
                        
                        if shouldPay and paymentAmount > 0 then
                            -- Natively push funds into the state bag and memory cache
                            player.Functions.AddMoney('bank', paymentAmount, 'paycheck')
                            
                            -- Trigger native UI notification
                            TriggerClientEvent('ox_lib:notify', src, {
                                title = 'Bank Deposit',
                                description = 'A paycheck of $' .. paymentAmount .. ' from ' .. jobConfig.label .. ' has cleared.',
                                type = 'success',
                                icon = 'building-columns'
                            })
                        end
                    end
                end
            end
        end
    end
end)
