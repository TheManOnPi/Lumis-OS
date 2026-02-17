-- LUMIS-OS v1.4.1 (STABLE CORE)
-- No paintutils, no external APIs, full clipping support.

local w, h = term.getSize()
local menuOpen = false
local theme = { 
    bg = colors.gray, 
    bar = colors.black, 
    accent = colors.blue, 
    text = colors.white, 
    app = colors.lightGray 
}

-- CUSTOM DRAWING ENGINE
local function drawRect(x, y, width, height, color)
    term.setBackgroundColor(color)
    for i = 0, height - 1 do
        local cy = y + i
        -- Vertical Clipping: Only draw if on screen
        if cy >= 1 and cy <= h then
            term.setCursorPos(x, cy)
            -- Horizontal Clipping: Ensure we don't write past width
            local displayW = width
            if x + width > w + 1 then displayW = w - x + 1 end
            if displayW > 0 then
                term.write(string.rep(" ", displayW))
            end
        end
    end
end

-- GLOBAL FRAMEWORK (LFrame)
_G.LFrame = {
    init = function(title)
        drawRect(1, 1, w, h, theme.app) -- Window Body
        drawRect(1, 1, w, 1, theme.accent) -- Header
        term.setCursorPos(2, 1)
        term.setTextColor(colors.white)
        term.write("X  " .. tostring(title):upper())
        term.setTextColor(colors.black)
    end,
    isClicked = function(mx, my, x, y, width, height)
        return mx >= x and mx <= x + (width - 1) and my >= y and my <= y + (height - 1)
    end
}

local function drawDesktop()
    drawRect(1, 1, w, h, theme.bg) -- Desktop Background
    
    local apps = fs.list("/lumis/apps")
    local ix, iy = 3, 2
    for _, name in ipairs(apps) do
        -- Draw Icon if it fits on screen
        if iy + 3 < h then
            drawRect(ix, iy, 6, 3, theme.app)
            term.setCursorPos(ix + 1, iy + 1)
            term.setBackgroundColor(theme.app)
            term.setTextColor(theme.accent)
            term.write(name:sub(1, 4))
            
            term.setCursorPos(ix, iy + 3)
            term.setBackgroundColor(theme.bg)
            term.setTextColor(theme.text)
            term.write(name:sub(1, 7))
            
            ix = ix + 9
            if ix > w - 6 then ix = 3; iy = iy + 5 end
        end
    end

    -- Taskbar
    drawRect(1, h, w, 1, theme.bar)
    term.setCursorPos(2, h)
    term.setTextColor(theme.accent)
    term.write("LUMIS")
    
    -- Start Menu
    if menuOpen then
        drawRect(1, h - 2, 10, 2, colors.white)
        term.setCursorPos(2, h - 1)
        term.setBackgroundColor(colors.white)
        term.setTextColor(colors.black)
        term.write("SHUTDOWN")
    end
end

-- MAIN OS LOOP
while true do
    drawDesktop()
    local event, button, mx, my = os.pullEvent("mouse_click")

    if my == h and mx <= 10 then
        menuOpen = not menuOpen
    elseif menuOpen and LFrame.isClicked(mx, my, 1, h - 1, 10, 1) then
        os.shutdown()
    elseif not menuOpen then
        -- App Launcher
        local list = fs.list("/lumis/apps")
        local ax, ay = 3, 2
        for _, name in ipairs(list) do
            if LFrame.isClicked(mx, my, ax, ay, 6, 3) then
                term.setBackgroundColor(colors.black)
                term.clear()
                term.setCursorPos(1,1)
                -- Run app with error protection
                local ok, err = pcall(function() shell.run("/lumis/apps/"..name) end)
                if not ok then
                    term.setBackgroundColor(colors.black)
                    term.clear()
                    print("App Crash: "..err)
                    sleep(2)
                end
                break
            end
            ax = ax + 9
            if ax > w - 6 then ax = 3; ay = ay + 5 end
        end
    else
        menuOpen = false
    end
end
