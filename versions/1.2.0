-- Lumis-OS GUI v2.0 Installer (Framework Edition)
local repo = "https://raw.githubusercontent.com/TheManOnPi/Lumis-OS/main/"
local sys = "/lumis/system/"
local apps = "/lumis/apps/"

-- 1. THE GUI FRAMEWORK (The API for apps)
local framework = [[
_G.LFrame = {}

function LFrame.init(title)
    local w, h = term.getSize()
    term.setBackgroundColor(colors.gray)
    term.clear()
    -- Draw Window Header
    term.setCursorPos(1,1)
    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.white)
    term.clearLine()
    print(" [X] " .. title)
    term.setBackgroundColor(colors.black)
    term.setCursorPos(1,2)
    return w, h
end

function LFrame.button(x, y, text, bg, fg)
    term.setCursorPos(x, y)
    term.setBackgroundColor(bg)
    term.setTextColor(fg)
    write(" " .. text .. " ")
end

function LFrame.checkClick(x, y, bx, by, bw, bh)
    return x >= bx and x <= bx + bw and y >= by and y <= by + bh
end
]]

-- 2. THE SETTINGS APP
local settingsApp = [[
local conf = Lumis.loadConfig()
while true do
    LFrame.init("Settings")
    print("\n Change Desktop Color:")
    LFrame.button(2, 4, "Blue", colors.blue, colors.white)
    LFrame.button(10, 4, "Red", colors.red, colors.white)
    LFrame.button(18, 4, "Green", colors.green, colors.white)
    print("\n\n [Click X to Exit]")

    local e, b, x, y = os.pullEvent("mouse_click")
    if LFrame.checkClick(x, y, 2, 1, 3, 0) then break end -- Exit
    if LFrame.checkClick(x, y, 2, 4, 6, 0) then conf.bg = colors.blue end
    if LFrame.checkClick(x, y, 10, 4, 5, 0) then conf.bg = colors.red end
    if LFrame.checkClick(x, y, 18, 4, 7, 0) then conf.bg = colors.green end
    Lumis.saveConfig(conf)
end
]]

-- 3. THE APP STORE
local appStore = [[
LFrame.init("App Store")
print("Connecting to Lumis Repo...")
local indexURL = "https://raw.githubusercontent.com/TheManOnPi/Lumis-OS/main/AppStore/AppIndex"
local res = http.get(indexURL)
if res then
    local appList = textutils.unserialiseJSON(res.readAll())
    res.close()
    LFrame.init("App Store")
    for i, name in ipairs(appList) do
        print(i .. ". " .. name)
        LFrame.button(15, i+2, "Install", colors.lime, colors.black)
    end
    
    local e, b, x, y = os.pullEvent("mouse_click")
    -- Installation logic based on Y coord
    local choice = y - 2
    if appList[choice] and x >= 15 then
        print("Downloading " .. appList[choice] .. "...")
        local appData = http.get("https://raw.githubusercontent.com/TheManOnPi/Lumis-OS/main/AppStore/" .. appList[choice] .. ".lua")
        if appData then
            local f = fs.open("/lumis/apps/" .. appList[choice], "w")
            f.write(appData.readAll())
            f.close()
            print("Done!")
            sleep(1)
        end
    end
else
    print("Could not connect.")
    sleep(2)
end
]]

-- 4. THE KERNEL (Now supports Config & Framework)
local kernel = [[
shell.run("/lumis/system/framework.lua")

_G.Lumis = {}
function Lumis.saveConfig(t)
    local f = fs.open("/lumis/system/config.dat", "w")
    f.write(textutils.serialize(t))
    f.close()
end
function Lumis.loadConfig()
    if not fs.exists("/lumis/system/config.dat") then return {bg = colors.lightBlue} end
    local f = fs.open("/lumis/system/config.dat", "r")
    local d = textutils.unserialize(f.readAll())
    f.close()
    return d
end

local function drawDesktop()
    local conf = Lumis.loadConfig()
    term.setBackgroundColor(conf.bg)
    term.clear()
    
    -- Draw Taskbar
    local w, h = term.getSize()
    term.setCursorPos(1, h)
    term.setBackgroundColor(colors.gray)
    term.clearLine()
    term.write(" LUMIS-OS")
    
    -- Draw Icons
    local apps = fs.list("/lumis/apps")
    for i, name in ipairs(apps) do
        term.setCursorPos(2, i + 1)
        term.setBackgroundColor(colors.yellow)
        term.write("  ")
        term.setBackgroundColor(conf.bg)
        term.write(" " .. name)
    end
end

while true do
    drawDesktop()
    local e, b, x, y = os.pullEvent("mouse_click")
    local apps = fs.list("/lumis/apps")
    if y > 1 and y <= #apps + 1 then
        shell.run("/lumis/apps/" .. apps[y-1])
    end
end
]]

-- Save everything to disk
local function save(path, data)
    local f = fs.open(path, "w")
    f.write(data)
    f.close()
end

save(sys .. "framework.lua", framework)
save(sys .. "kernel.lua", kernel)
save(apps .. "Settings", settingsApp)
save(apps .. "AppStore", appStore)

print("Lumis-OS Upgraded! Rebooting...")
sleep(1)
os.reboot()
