const fs = require('fs');
const path = require('path');

function walk(dir, callback) {
    fs.readdirSync(dir).forEach(f => {
        let dirPath = path.join(dir, f);
        let isDirectory = fs.statSync(dirPath).isDirectory();
        isDirectory ? walk(dirPath, callback) : callback(path.join(dir, f));
    });
}

walk(__dirname, (filePath) => {
    if (!filePath.endsWith('.lua')) return;
    let content = fs.readFileSync(filePath, 'utf8');
    let original = content;

    // 1. Remove QBCore instantiations
    content = content.replace(/local QBCore = exports\['qb-core'\]:GetCoreObject\(\)/g, "local Core = exports['ag_core']:GetCoreObject()");
    content = content.replace(/QBCore = exports\['qb-core'\]:GetCoreObject\(\)/g, "Core = exports['ag_core']:GetCoreObject()");
    
    // Replace leftover QBCore variables with Core
    content = content.replace(/QBCore\./g, "Core.");

    // 2. Fix Notifications using ox_lib native
    // Server: Core.Functions.Notify(src, text, type) -> TriggerClientEvent('ox_lib:notify')
    content = content.replace(/Core\.Functions\.Notify\(([^,]+),\s*([^,]+)(?:,\s*([^,]+))?(?:,\s*([^,)]+))?\)/g, (match, src, text, type) => {
        // If the first argument is a string (e.g. locale or text), it's a client call inside a server file (rare but happens)
        if (src.includes('"') || src.includes("'") || src.includes('locale')) return match; 
        type = type && type.trim() !== 'nil' ? type.trim() : "'info'";
        return `TriggerClientEvent('ox_lib:notify', ${src}, { type = ${type}, description = ${text} })`;
    });

    // 3. Fix Permissions native to FiveM ACE
    content = content.replace(/Core\.Functions\.HasPermission\(([^,]+),\s*([^)]+)\)/g, "IsPlayerAceAllowed($1, 'command')");
    
    // 4. QBCore.Functions.GetQBPlayers -> Core.Functions.GetPlayers
    content = content.replace(/Core\.Functions\.GetQBPlayers/g, "Core.Functions.GetPlayers");

    if (content !== original) {
        fs.writeFileSync(filePath, content, 'utf8');
        console.log("Refactored: " + filePath);
    }
});
