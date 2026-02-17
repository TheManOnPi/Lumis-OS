-- Lumis-OS Master Bootstrapper
local repoURL = "https://raw.githubusercontent.com/TheManOnPi/Lumis-OS/main/versions/"
local latestURL = repoURL .. "latest"

term.setTextColor(colors.yellow)
print("Initializing Lumis-OS...")

-- 1. Create Protected Directory Structure
-- System = Gets updated | Apps & User = Persistent
local dirs = {"/lumis/system", "/lumis/apps", "/lumis/user"}
for _, d in ipairs(dirs) do
    if not fs.exists(d) then fs.makeDir(d) end
end

-- 2. Create the Intelligent Bootloader
-- This file stays on the computer and handles updates every boot
local bootloaderCode = [[
local repo = "]] .. repoURL .. [["
local latestURL = "]] .. latestURL .. [["
local sys = "/lumis/system/"

local function getRemoteVersion()
    if not http then return nil end
    local res = http.get(latestURL)
    if res then
        local ver = res.readAll():gsub("%s+", "")
        res.close()
        return ver
    end
    return nil
end

local function update()
    term.setTextColor(colors.cyan)
    print("Checking for Lumis-OS updates...")
    
    local remoteVer = getRemoteVersion()
    if not remoteVer then 
        print("Offline: Skipping update.")
        return 
    end

    local localVer = "0"
    if fs.exists(sys .. "version") then
        local f = fs.open(sys .. "version", "r")
        localVer = f.readAll():gsub("%s+", "")
        f.close()
    end

    if remoteVer ~= localVer then
        print("New version found: v" .. remoteVer)
        print("Downloading system scripts...")
        
        -- ONLY download and overwrite the system kernel
        local res = http.get(repo .. remoteVer .. ".lua")
        if res then
            local f = fs.open(sys .. "kernel.lua", "w")
            f.write(res.readAll())
            f.close()
            res.close()
            
            local vf = fs.open(sys .. "version", "w")
            vf.write(remoteVer)
            vf.close()
            print("Update complete!")
        else
            print("Update failed: Could not fetch script.")
        end
    else
        print("System is up to date.")
    end
end

update()

-- Boot into the Kernel
if fs.exists(sys .. "kernel.lua") then
    shell.run(sys .. "kernel.lua")
else
    print("Error: Kernel missing. Please reinstall.")
end
]]

-- Save the bootloader as startup.lua
local f = fs.open("startup.lua", "w")
f.write(bootloaderCode)
f.close()

print("Bootloader installed.")
print("Triggering first-time update...")

-- 3. Execute the newly created startup to pull the OS for the first time
print("Welcome to Lumis.")
shell.run("startup.lua")
