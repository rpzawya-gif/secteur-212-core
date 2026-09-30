local messages = {}

-- Staff Chat
RegisterNetEvent('ps-adminmenu:server:sendMessageServer', function(message, citizenid, fullname)
    if not CheckPerms(source, 'mod') then return end

    local time = os.time() * 1000
    local players = Core.Functions.GetPlayers()

    for i = 1, #players, 1 do
        local player = players[i]
            if Core.Functions.IsOptin(player) then
                TriggerClientEvent('ox_lib:notify', player, { type = 'inform', description = locale("new_staffchat" }))
            end
        end

    messages[#messages + 1] = { message = message, citizenid = citizenid, fullname = fullname, time = time }
end)


lib.callback.register('ps-adminmenu:callback:GetMessages', function()
    if not CheckPerms(source, 'mod') then return {} end
    return messages
end)
