-- Window Mover for Hammerspoon
-- Move windows by holding Command + Left Mouse Button and dragging
-- File: window-mover.lua

local mover = {}
mover.isDragging = false
mover.draggedWindow = nil
mover.startMousePos = nil
mover.startWindowPos = nil
mover.dragTimer = nil

-- Function to update window position while dragging
local function updateWindowPosition()
    if mover.isDragging and mover.draggedWindow then
        local currentMousePos = hs.mouse.absolutePosition()
        local deltaX = currentMousePos.x - mover.startMousePos.x
        local deltaY = currentMousePos.y - mover.startMousePos.y
        
        local newX = mover.startWindowPos.x + deltaX
        local newY = mover.startWindowPos.y + deltaY
        
        mover.draggedWindow:setTopLeft({x = newX, y = newY})
    end
end

-- Function to get window under mouse
local function getWindowUnderMouse(mousePos)
    for _, win in ipairs(hs.window.orderedWindows()) do
        if win:isVisible() then
            local frame = win:frame()
            if mousePos.x >= frame.x and mousePos.x <= (frame.x + frame.w) and
                mousePos.y >= frame.y and mousePos.y <= (frame.y + frame.h) then
                return win
            end
        end
    end
    return nil
end

-- Mouse event tap for detecting Command + Left Click
mover.mouseTap = hs.eventtap.new(
    {hs.eventtap.event.types.leftMouseDown, hs.eventtap.event.types.leftMouseUp},
    function(event)
        local eventType = event:getType()
        local flags = event:getFlags()
        
        -- Check if ONLY Command key is pressed (not with Option)
        if flags.cmd and not flags.alt then
            if eventType == hs.eventtap.event.types.leftMouseDown then
                local mousePos = hs.mouse.absolutePosition()
                local windowUnderMouse = getWindowUnderMouse(mousePos)
                
                if windowUnderMouse then
                    print("[Mover] Starting window move: " .. windowUnderMouse:title())
                    mover.isDragging = true
                    mover.draggedWindow = windowUnderMouse
                    mover.startMousePos = mousePos
                    mover.startWindowPos = windowUnderMouse:topLeft()
                    
                    windowUnderMouse:focus()
                    
                    if mover.dragTimer then
                        mover.dragTimer:stop()
                    end
                    mover.dragTimer = hs.timer.doWhile(
                        function() return mover.isDragging end,
                        updateWindowPosition,
                        0.01
                    )
                    
                    return true
                end
                
            elseif eventType == hs.eventtap.event.types.leftMouseUp then
                if mover.isDragging then
                    print("[Mover] Window move ended")
                    mover.isDragging = false
                    
                    if mover.dragTimer then
                        mover.dragTimer:stop()
                        mover.dragTimer = nil
                    end
                    
                    mover.draggedWindow = nil
                    mover.startMousePos = nil
                    mover.startWindowPos = nil
                    
                    return true
                end
            end
        end
        
        return false
    end
)

-- Start the mouse tap
mover.mouseTap:start()

print("[Mover] Window Mover loaded - Use Cmd + Left Click to move windows")
