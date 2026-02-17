-- LUMIS-OS v1.4.0 (CORE)
local w, h = term.getSize()
local menuOpen = false

-- Theme & Config
local theme = { bg = colors.gray, bar = colors.black, accent = colors.blue, text = colors.white, app = colors.lightGray }

-- SAFE DRAWING ENGINE (Replaces Paintutils)
local function drawRect(x, y, width, height, color)
    term.setBackgroundColor(color)
    for i = 0, height - 1 do
        local currY = y + i
        if currY >= 1 and currY <= h then -- Vertical Clipping
            term.setCursorPos(math.max(1, x), currY)
            local drawW = width
            if x + width > w + 1 then drawW = w - x + 1 end -- Horizontal Clipping
            if drawW > 0 then
                term.write(string.rep(" ", drawW))
            end
        end
    end
end

-- GLOBAL FRAMEWORK
_G.LFrame = {
    init = function(title)
        drawRect(1, 1, w, h, theme.app)
        drawRect(1, 1, w, 1, theme.accent)
        term.setCursorPos(2, 1)
        term.setTextColor(colors.white)
        write("X  " .. title:upper())
        term.setTextColor(colors.black)
    end,
    isClicked = function(mx, my, x, y, width, height)
        return mx >= x and mx <= x + (width - 1) and my >= y and my <= y + (height - 1)
    end
}

local function drawDesktop()
    drawRect(1, 1, w, h, theme.bg) -- Background
    
    local apps = fs.list("/lumis/apps")
    local x, y = 3, 2
    for _, name in ipairs(apps) do
        if y + 3 < h then
            drawRect(x, y, 6, 3, theme.app) -- App Icon Box
            term.setCursorPos(x + 1, y + 1)
            term.setBackgroundColor(theme.app)
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
    drawRect(1, h, w, 1, theme.bar)
    term.setCursorPos(2, h)
    term.setTextColor(theme.accent)
    write("LUMIS")
    
    if menuOpen then
        drawRect(1, h - 2, 10, 2, colors.white)
        term.setCursorPos(2, h - 1)
        term.setBackgroundColor(colors.white)
        term.setTextColor(colors.black)
        write("SHUTDOWN")
    end
end

-- MAIN ENGINE
while true do
    drawDesktop()
    local e, b, mx, my = os.pullEvent("mouse_click")

    if my == h and mx <= 10 then
        menuOpen = not menuOpen
    elseif menuOpen and LFrame.isClicked(mx, my, 1, h - 1, 10, 1) then
        os.shutdown()
    elseif not menuOpen then
        local list = fs.list("/lumis/apps")
        local ax, ay = 3, 2
        for _, name in ipairs(list) do
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
