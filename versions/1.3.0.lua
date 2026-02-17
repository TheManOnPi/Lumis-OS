-- LUMIS-OS MODERN KERNEL
local w, h = term.getSize()
local menuOpen = false

-- Theme Palette
local theme = {
    desktop = colors.gray,
    taskbar = colors.black,
    accent = colors.blue,
    text = colors.white,
    appBg = colors.lightGray,
    icon = colors.white
}

_G.LFrame = {
    -- Modern Window Frame
    init = function(title)
        term.setBackgroundColor(theme.appBg)
        term.clear()
        -- Header Bar
        paintutils.drawFilledRect(1, 1, w, 1, theme.accent)
        term.setCursorPos(2, 1)
        term.setTextColor(colors.white)
        write("x " .. title:upper())
        term.setCursorPos(1, 2)
        term.setBackgroundColor(theme.appBg)
        term.setTextColor(colors.black)
    end,
    isClicked = function(mx, my, x, y, width, height)
        return mx >= x and mx <= x + width - 1 and my >= y and my <= y + height - 1
    end
}

local function drawDesktop()
    -- Draw Background
    term.setBackgroundColor(theme.desktop)
    term.clear()
    
    -- Draw Icon Grid
    local files = fs.list("/lumis/apps")
    local x, y = 3, 2
    for _, name in ipairs(files) do
        -- Icon Shadow/Box
        paintutils.drawFilledRect(x, y, x + 5, y + 2, colors.lightGray)
        term.setCursorPos(x + 1, y + 1)
        term.setBackgroundColor(colors.lightGray)
        term.setTextColor(theme.accent)
        write(name:sub(1,4))
        
        -- Label
        term.setCursorPos(x, y + 3)
        term.setBackgroundColor(theme.desktop)
        term.setTextColor(colors.white)
        write(name:sub(1,6))

        x = x + 9
        if x > w - 5 then x = 3; y = y + 5 end
    end

    -- Modern Taskbar (Blurry/Black style)
    paintutils.drawFilledRect(1, h, w, h, theme.taskbar)
    term.setCursorPos(2, h)
    term.setTextColor(theme.accent)
    write("\15") -- Geometric symbol for Start
    
    term.setTextColor(colors.white)
    term.setCursorPos(6, h)
    write("LUMIS")

    -- Clock
    local time = textutils.formatTime(os.time(), true)
    term.setCursorPos(w - #time, h)
    write(time)

    if menuOpen then
        paintutils.drawFilledRect(1, h - 4, 12, h - 1, colors.lightGray)
        term.setTextColor(colors.black)
        term.setBackgroundColor(colors.lightGray)
        term.setCursorPos(2, h - 3)
        write("Settings")
        term.setCursorPos(2, h - 2)
        write("Power Off")
    end
end

while true do
    drawDesktop()
    local e, b, mx, my = os.pullEvent("mouse_click")

    if my == h and mx <= 10 then
        menuOpen = not menuOpen
    elseif menuOpen and LFrame.isClicked(mx, my, 1, h - 2, 12, 1) then
        os.shutdown()
    elseif not menuOpen then
        -- App Launch Detection
        local files = fs.list("/lumis/apps")
        local ax, ay = 3, 2
        for _, name in ipairs(files) do
            if LFrame.isClicked(mx, my, ax, ay, 6, 3) then
                term.setBackgroundColor(colors.black)
                term.clear()
                term.setCursorPos(1,1)
                pcall(function() shell.run("/lumis/apps/"..name) end)
                break
            end
            ax = ax + 9
            if ax > w - 5 then ax = 3; ay = ay + 5 end
        end
    else
        menuOpen = false
    end
end
