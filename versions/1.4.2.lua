-- LUMIS-OS v1.4.2 (STABLE CORE + APP MENU)
local w, h = term.getSize()
local menuOpen = false
local theme = { bg = colors.gray, bar = colors.black, accent = colors.blue, text = colors.white, app = colors.lightGray }

-- SAFE DRAWING ENGINE
local function drawRect(x, y, width, height, color)
    term.setBackgroundColor(color)
    for i = 0, height - 1 do
        local cy = y + i
        if cy >= 1 and cy <= h then
            term.setCursorPos(x, cy)
            local displayW = width
            if x + width > w + 1 then displayW = w - x + 1 end
            if displayW > 0 then term.write(string.rep(" ", displayW)) end
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
        term.write("X  " .. tostring(title):upper())
        term.setTextColor(colors.black)
    end,
    isClicked = function(mx, my, x, y, width, height)
        return mx >= x and mx <= x + (width - 1) and my >= y and my <= y + (height - 1)
    end
}

local function drawDesktop()
    drawRect(1, 1, w, h, theme.bg) -- Clean Background
    
    -- Taskbar
    drawRect(1, h, w, 1, theme.bar)
    term.setCursorPos(2, h)
    term.setTextColor(theme.accent)
    term.write("\15 LUMIS") -- Start Button

    -- THE APP MENU (Vertical List)
    if menuOpen then
        local apps = fs.list("/lumis/apps")
        local menuHeight = #apps + 2
        local menuY = h - menuHeight
        
        -- Draw Menu Box
        drawRect(1, menuY, 12, menuHeight, colors.white)
        
        -- List Apps in Menu
        for i, name in ipairs(apps) do
            term.setCursorPos(2, menuY + i - 1)
            term.setBackgroundColor(colors.white)
            term.setTextColor(colors.black)
            term.write(name:sub(1, 10))
        end
        
        -- Power Options at the bottom of menu
        drawRect(1, h-1, 12, 1, colors.lightGray)
        term.setCursorPos(2, h-1)
        term.setTextColor(colors.red)
        term.write("SHUTDOWN")
    end
end

-- MAIN ENGINE
while true do
    drawDesktop()
    local e, b, mx, my = os.pullEvent("mouse_click")

    if my == h and mx <= 10 then
        menuOpen = not menuOpen
    elseif menuOpen then
        local apps = fs.list("/lumis/apps")
        local menuHeight = #apps + 2
        local menuY = h - menuHeight
        
        -- Check if an App in the menu was clicked
        local clickedApp = false
        for i, name in ipairs(apps) do
            if LFrame.isClicked(mx, my, 1, menuY + i - 1, 12, 1) then
                menuOpen = false
                term.setBackgroundColor(colors.black)
                term.clear()
                term.setCursorPos(1,1)
                pcall(function() shell.run("/lumis/apps/"..name) end)
                clickedApp = true
                break
            end
        end
        
        -- Check Shutdown
        if not clickedApp and LFrame.isClicked(mx, my, 1, h-1, 12, 1) then
            os.shutdown()
        end
        
        -- Close menu if clicking outside
        if not clickedApp then menuOpen = false end
    end
end
