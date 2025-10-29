-- Window Resizer for Hammerspoon
-- Resize windows by holding Option + Command + Left Mouse Button and dragging
-- File: window-resizer.lua

local resizer = {}
resizer.isResizing = false
resizer.resizedWindow = nil
resizer.startMousePos = nil
resizer.startWindowFrame = nil
resizer.resizeTimer = nil

-- Function to update window size while resizing
local function updateWindowSize()
    if resizer.isResizing and resizer.resizedWindow then
        local currentMousePos = hs.mouse.absolutePosition()
        local deltaX = currentMousePos.x - resizer.startMousePos.x
        local deltaY = currentMousePos.y - resizer.startMousePos.y
        
        -- Calculate new size based on mouse movement
        local newWidth = resizer.startWindowFrame.w + deltaX
        local newHeight = resizer.startWindowFrame.h + deltaY
        
        -- Set minimum size to prevent window from becoming too small
        local minWidth = 200
        local minHeight = 100
        
        if newWidth < minWidth then
            newWidth = minWidth
        end
        if newHeight < minHeight then
            newHeight = minHeight
        end
        
        -- Create new frame with updated size (keep top-left corner fixed)
        local newFrame = {
            x = resizer.startWindowFrame.x,
            y = resizer.startWindowFrame.y,
            w = newWidth,
            h = newHeight
        }
        
        -- Force immediate update
        resizer.resizedWindow:setFrame(newFrame, 0)
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

-- Mouse event tap for detecting Option + Command + Left Click
resizer.mouseTap = hs.eventtap.new(
    {hs.eventtap.event.types.leftMouseDown, hs.eventtap.event.types.leftMouseUp},
    function(event)
        local eventType = event:getType()
        local flags = event:getFlags()
        
        -- Check if BOTH Option (alt) and Command keys are pressed
        if flags.alt and flags.cmd then
            if eventType == hs.eventtap.event.types.leftMouseDown then
                local mousePos = hs.mouse.absolutePosition()
                local windowUnderMouse = getWindowUnderMouse(mousePos)
                
                if windowUnderMouse then
                    print("[Resizer] Starting window resize: " .. windowUnderMouse:title())
                    resizer.isResizing = true
                    resizer.resizedWindow = windowUnderMouse
                    resizer.startMousePos = mousePos
                    resizer.startWindowFrame = windowUnderMouse:frame()
                    
                    windowUnderMouse:focus()
                    
                    if resizer.resizeTimer then
                        resizer.resizeTimer:stop()
                    end
                    resizer.resizeTimer = hs.timer.doWhile(
                        function() return resizer.isResizing end,
                        updateWindowSize,
                        0.005  -- Update every 5ms for very smooth real-time resizing
                    )
                    
                    return true
                end
                
            elseif eventType == hs.eventtap.event.types.leftMouseUp then
                if resizer.isResizing then
                    print("[Resizer] Window resize ended")
                    resizer.isResizing = false
                    
                    if resizer.resizeTimer then
                        resizer.resizeTimer:stop()
                        resizer.resizeTimer = nil
                    end
                    
                    resizer.resizedWindow = nil
                    resizer.startMousePos = nil
                    resizer.startWindowFrame = nil
                    
                    return true
                end
            end
        end
        
        return false
    end
)

-- Start the mouse tap
resizer.mouseTap:start()

print("[Resizer] Window Resizer loaded - Use Opt + Cmd + Left Click to resize windows")
