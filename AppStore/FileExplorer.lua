-- Lumis-OS File Explorer (Modular App)
local path = "/"
local selected = nil

local function getFiles(p)
    local list = fs.list(p)
    table.sort(list)
    return list
end

while true do
    local w, h = LFrame.init("Explorer: " .. path)
    local files = getFiles(path)
    
    -- Draw "Back" button if not in root
    if path ~= "/" then
        LFrame.button(2, 3, ".. [Back]", colors.gray, colors.white)
    end

    -- List Files/Folders
    for i, file in ipairs(files) do
        local yPos = i + (path == "/" and 2 or 3)
        if yPos < h - 1 then
            local isDir = fs.isDir(fs.combine(path, file))
            local col = isDir and colors.yellow or colors.lightGray
            LFrame.button(2, yPos, (isDir and "[D] " or "[F] ") .. file, col, colors.black)
        end
    end

    -- Bottom Bar for Actions
    term.setCursorPos(1, h)
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.black)
    term.clearLine()
    write(" Selected: " .. (selected or "None"))
    if selected then
        LFrame.button(w - 7, h, "DEL", colors.red, colors.white)
    end

    -- Event Handling
    local e, b, x, y = os.pullEvent("mouse_click")
    
    -- Close App
    if LFrame.isClicked(x, y, 1, 1, 5, 1) then break end

    -- Handle Navigation/Selection
    local offset = (path == "/" and 2 or 3)
    if LFrame.isClicked(x, y, 2, 3, 10, 1) and path ~= "/" then
        path = fs.getName(fs.getDir(path)) == ".." and "/" or fs.getDir(path)
        selected = nil
    elseif y > offset and y < h then
        local idx = y - offset
        if files[idx] then
            local fullPath = fs.combine(path, files[idx])
            if fs.isDir(fullPath) then
                path = fullPath
                selected = nil
            else
                selected = files[idx]
            end
        end
    end

    -- Handle Deletion
    if selected and LFrame.isClicked(x, y, w - 7, h, 5, 1) then
        fs.delete(fs.combine(path, selected))
        selected = nil
    end
end
