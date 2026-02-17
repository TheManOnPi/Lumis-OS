-- LUMIS-OS v1.3.1 (ULTIMA)
if not paintutils then os.loadAPI("rom/apis/paintutils.lua") end

local w, h = term.getSize()
local menuOpen = false

-- Color Palette
local theme = {
    bg = colors.gray,
    bar = colors.black,
    accent = colors.blue,
    text = colors.white,
    app = colors.lightGray
}

-- GLOBAL API
_G.LFrame = {
    init = function(title)
        term.setBackgroundColor(theme.app)
        term.clear()
        -- Header
        paintutils.drawFilledRect(1, 1, w, 1, theme.accent)
        term.setCursorPos(2, 1)
        term.setTextColor(colors.white)
        write("X  " .. title:upper())
        term.setCursorPos(1, 2)
        term.setTextColor(colors.black)
    end,
    -- Enhanced Click Detector
    isClicked = function(mx, my, x, y, width, height)
        return mx >= x and mx <= x + (width - 1) and my >= y and my <= y + (height - 1)
    end
}

local function drawDesktop()
    term.setBackgroundColor(theme.bg)
    term.clear()
    
    -- Icon Grid with Boundary Checks
    local files = fs.list("/lumis/apps")
    local x, y = 3, 2
    for _, name in ipairs(files) do
        -- ONLY draw if within screen height (prevents line 44 error)
        if y + 3 < h then
            paintutils.drawFilledRect(x, y, x + 5, y + 2, colors.lightGray)
            term.setCursorPos(x + 1, y + 1)
            term.setBackgroundColor(colors.lightGray)
            term.setTextColor(theme.accent)
            write(name:sub(1, 4))
            
            term.setCursorPos(x, y + 3)
            term.setBackgroundColor(theme.bg)
            term.setTextColor(theme.text)
            write(name:sub(1, 7))

            x = x + 9
            if x > w - 6 then x = 3; y = y + 5 end
        end
    end

    -- Taskbar
    paintutils.drawFilledRect(1, h, w, h, theme.bar)
    term.setCursorPos(2, h)
    term.setTextColor(theme.accent)
    write("\15 LUMIS")
    
    local time = textutils.formatTime(os.time(), true)
    term.setCursorPos(w - #time, h)
    term.setTextColor(theme.text)
    write(time)

    -- Start Menu
    if menuOpen then
        paintutils.drawFilledRect(1, h - 3, 10, h - 1, colors.white)
        term.setTextColor(colors.black)
        term.setBackgroundColor(colors.white)
        term.setCursorPos(2, h - 2)
        write("Shutdown")
        term.setCursorPos(2, h - 1)
        write("Reboot")
    end
end

-- SYSTEM LOOP
while true do
    drawDesktop()
    local e, b, mx, my = os.pullEvent("mouse_click")

    -- Taskbar Logic
    if my == h and mx <= 10 then
        menuOpen = not menuOpen
    elseif menuOpen and LFrame.isClicked(mx, my, 1, h-2, 10, 1) then
        os.shutdown()
    elseif menuOpen and LFrame.isClicked(mx, my, 1, h-1, 10, 1) then
        os.reboot()
    elseif not menuOpen then
        -- App Launching
        local apps = fs.list("/lumis/apps")
        local ax, ay = 3, 2
        for _, name in ipairs(apps) do
            if LFrame.isClicked(mx, my, ax, ay, 6, 3) then
                term.setBackgroundColor(colors.black)
                term.clear()
                term.setCursorPos(1,1)
                pcall(function() shell.run("/lumis/apps/"..name) end)
                break
            end
            ax = ax + 9
            if ax > w - 6 then ax = 3; ay = ay + 5 end
        end
    else
        menuOpen = false
    end
end
