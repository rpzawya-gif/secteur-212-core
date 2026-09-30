Core = Core or {}
Core.Functions = Core.Functions or {}

-- [[ NATIVE PERMISSIONS MODULE ]]
-- Master Directive v2.0 Compliant
-- This module completely replaces QBCore permission groups.
-- It natively links with FiveM's built-in ACE system without any middleware databases.

-- HOW TO USE IN SERVER.CFG:
-- add_principal identifier.license2:xxxxxxxx ag_core.god
-- add_principal identifier.license2:yyyyyyyy ag_core.admin
-- add_principal identifier.license2:zzzzzzzz ag_core.mod

Core.Functions.HasPermission = function(source, permission)
    -- If no permission is requested, default to checking for basic admin access
    if not permission then return IsPlayerAceAllowed(source, 'ag_core.admin') end

    -- Always allow 'god' role to bypass everything
    if IsPlayerAceAllowed(source, 'ag_core.god') then return true end

    -- If a specific string permission is passed (e.g., 'admin', 'mod')
    if type(permission) == 'string' then
        return IsPlayerAceAllowed(source, 'ag_core.' .. string.lower(permission))
    end

    -- If an array of permissions is passed (e.g., {'admin', 'mod'})
    if type(permission) == 'table' then
        for _, p in pairs(permission) do
            if IsPlayerAceAllowed(source, 'ag_core.' .. string.lower(p)) then
                return true
            end
        end
    end

    return false
end

-- Get the highest permission level of a player for UI rendering in ps-adminmenu
Core.Functions.GetPermission = function(source)
    if IsPlayerAceAllowed(source, 'ag_core.god') then return 'god' end
    if IsPlayerAceAllowed(source, 'ag_core.admin') then return 'admin' end
    if IsPlayerAceAllowed(source, 'ag_core.mod') then return 'mod' end
    return 'user'
end

-- Native Export Endpoints
exports('HasPermission', Core.Functions.HasPermission)
exports('GetPermission', Core.Functions.GetPermission)
