-- Lumis-OS Master GUI Installer
local repo = "https://raw.githubusercontent.com/TheManOnPi/Lumis-OS/main/versions/"
local latestURL = repo .. "latest"

term.setTextColor(colors.cyan)
print("--- Lumis-OS Installation ---")

-- 1. Create File System
local folders = {"/lumis/system", "/lumis/apps", "/lumis/user"}
for _, f in ipairs(folders) do
    if not fs.exists(f) then fs.makeDir(f) end
end

-- 2. Create the Bootloader (startup)
-- This handles the GitHub updates automatically
local bootloader = [[
local repo = "]] .. repo .. [["
local latestURL = "]] .. latestURL .. [["
local sysPath = "/lumis/system/"

term.clear()
term.setCursorPos(1,1)
print("Lumis-OS Booting...")

if http then
    local res = http.get(latestURL)
    if res then
        local remoteVer = res.readAll():gsub("%s+", "")
        res.close()
        
        local currentVer = "0"
        if fs.exists(sysPath.."version") then
            local f = fs.open(sysPath.."version", "r")
            currentVer = f.readAll():gsub("%s+", "")
            f.close()
        end

        if remoteVer ~= currentVer then
            print("Updating to v"..remoteVer.."...")
            local pkg = http.get(repo .. remoteVer .. ".lua")
            if pkg then
                local f = fs.open(sysPath.."kernel.lua", "w")
                f.write(pkg.readAll())
                f.close()
                pkg.close()
                local v = fs.open(sysPath.."version", "w")
                v.write(remoteVer)
                v.close()
            end
        end
    end
end

if fs.exists(sysPath.."kernel.lua") then
    shell.run(sysPath.."kernel.lua")
else
    print("Error: Kernel not found!")
end
]]

local f = fs.open("startup", "w")
f.write(bootloader)
f.close()

-- 3. Create the GUI Kernel
local kernel = [[
local w, h = term.getSize()
local menuOpen = false

local function drawIcon(x, y, name)
    term.setBackgroundColor(colors.yellow)
    for i=0,2 do
        term.setCursorPos(x, y+i)
        term.write("     ")
    end
    term.setCursorPos(x, y+3)
    term.setBackgroundColor(colors.lightBlue)
    term.setTextColor(colors.black)
    term.write(name:sub(1,5))
end

local function render()
    term.setBackgroundColor(colors.lightBlue)
    term.clear()
    
    -- Desktop Icons
    local apps = fs.list("/lumis/apps")
    local ix, iy = 2, 2
    for _, app in ipairs(apps) do
        drawIcon(ix, iy, app)
        ix = ix + 8
        if ix > w-5 then ix=2; iy=iy+5 end
    end

    -- Taskbar
    term.setCursorPos(1, h)
    term.setBackgroundColor(colors.gray)
    term.clearLine()
    term.setTextColor(colors.white)
    term.write(" LUMIS ")
    
    local time = textutils.formatTime(os.time(), true)
    term.setCursorPos(w - #time, h)
    term.write(time)

    if menuOpen then
        term.setBackgroundColor(colors.white)
        term.setTextColor(colors.black)
        term.setCursorPos(1, h-2)
        term.write(" Shutdown  ")
        term.setCursorPos(1, h-1)
        term.write(" Reboot    ")
    end
end

while true do
    render()
    local event, button, x, y = os.pullEvent("mouse_click")
    
    if y == h and x <= 7 then
        menuOpen = not menuOpen
    elseif menuOpen and x <= 11 and y == h-2 then
        os.shutdown()
    elseif menuOpen and x <= 11 and y == h-1 then
        os.reboot()
    else
        menuOpen = false
        -- App Launching logic
        local apps = fs.list("/lumis/apps")
        local ax, ay = 2, 2
        for _, app in ipairs(apps) do
            if x >= ax and x <= ax+4 and y >= ay and y <= ay+2 then
                term.setBackgroundColor(colors.black)
                term.clear()
                term.setCursorPos(1,1)
                shell.run("/lumis/apps/"..app)
                break
            end
            ax = ax + 8
            if ax > w-5 then ax=2; ay=ay+5 end
        end
    end
end
]]

local k = fs.open("/lumis/system/kernel.lua", "w")
k.write(kernel)
k.close()

-- 4. Initial Version File
local v = fs.open("/lumis/system/version", "w")
v.write("1.0")
v.close()

print("Installation Successful!")
print("Rebooting into Lumis-OS...")
sleep(2)
os.reboot()
