-- Window Resizer for Hammerspoon
-- Resize windows by holding Option + Command + Left Mouse Button and dragging
-- File: window-resizer.lua

local resizer = {}
resizer.isResizing = false
resizer.resizedWindow = nil
resizer.startMousePos = nil
resizer.startWindowFrame = nil
resizer.resizeTimer = nil
resizer.clickRegion = nil  -- Store which region was clicked (tl, tr, bl, br)

-- Function to detect which region of the window was clicked
-- Divides window into 4 equal quadrants: top-left, top-right, bottom-left, bottom-right
local function detectClickRegion(mousePos, windowFrame)
    local relativeX = mousePos.x - windowFrame.x
    local relativeY = mousePos.y - windowFrame.y
    local midX = windowFrame.w / 2
    local midY = windowFrame.h / 2

    if relativeX < midX then
        if relativeY < midY then
            return "tl"  -- top-left
        else
            return "bl"  -- bottom-left
        end
    else
        if relativeY < midY then
            return "tr"  -- top-right
        else
            return "br"  -- bottom-right
        end
    end
end

-- Function to update window size while resizing
local function updateWindowSize()
    if resizer.isResizing and resizer.resizedWindow then
        local currentMousePos = hs.mouse.absolutePosition()
        local deltaX = currentMousePos.x - resizer.startMousePos.x
        local deltaY = currentMousePos.y - resizer.startMousePos.y

        -- Set minimum size to prevent window from becoming too small
        local minWidth = 200
        local minHeight = 100

        local newFrame = {}

        -- Resize based on which region was clicked, keeping opposite corner fixed
        if resizer.clickRegion == "tl" then
            -- Top-left clicked: keep bottom-right corner fixed
            local fixedX = resizer.startWindowFrame.x + resizer.startWindowFrame.w
            local fixedY = resizer.startWindowFrame.y + resizer.startWindowFrame.h

            newFrame.x = resizer.startWindowFrame.x + deltaX
            newFrame.y = resizer.startWindowFrame.y + deltaY
            newFrame.w = fixedX - newFrame.x
            newFrame.h = fixedY - newFrame.y

            -- Apply minimum constraints
            if newFrame.w < minWidth then
                newFrame.x = fixedX - minWidth
                newFrame.w = minWidth
            end
            if newFrame.h < minHeight then
                newFrame.y = fixedY - minHeight
                newFrame.h = minHeight
            end

        elseif resizer.clickRegion == "tr" then
            -- Top-right clicked: keep bottom-left corner fixed
            local fixedX = resizer.startWindowFrame.x
            local fixedY = resizer.startWindowFrame.y + resizer.startWindowFrame.h

            newFrame.x = fixedX
            newFrame.y = resizer.startWindowFrame.y + deltaY
            newFrame.w = resizer.startWindowFrame.w + deltaX
            newFrame.h = fixedY - newFrame.y

            -- Apply minimum constraints
            if newFrame.w < minWidth then
                newFrame.w = minWidth
            end
            if newFrame.h < minHeight then
                newFrame.y = fixedY - minHeight
                newFrame.h = minHeight
            end

        elseif resizer.clickRegion == "bl" then
            -- Bottom-left clicked: keep top-right corner fixed
            local fixedX = resizer.startWindowFrame.x + resizer.startWindowFrame.w
            local fixedY = resizer.startWindowFrame.y

            newFrame.x = resizer.startWindowFrame.x + deltaX
            newFrame.y = fixedY
            newFrame.w = fixedX - newFrame.x
            newFrame.h = resizer.startWindowFrame.h + deltaY

            -- Apply minimum constraints
            if newFrame.w < minWidth then
                newFrame.x = fixedX - minWidth
                newFrame.w = minWidth
            end
            if newFrame.h < minHeight then
                newFrame.h = minHeight
            end

        else  -- "br" - bottom-right
            -- Bottom-right clicked: keep top-left corner fixed (original behavior)
            newFrame.x = resizer.startWindowFrame.x
            newFrame.y = resizer.startWindowFrame.y
            newFrame.w = resizer.startWindowFrame.w + deltaX
            newFrame.h = resizer.startWindowFrame.h + deltaY

            -- Apply minimum constraints
            if newFrame.w < minWidth then
                newFrame.w = minWidth
            end
            if newFrame.h < minHeight then
                newFrame.h = minHeight
            end
        end

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
                    local windowFrame = windowUnderMouse:frame()
                    resizer.clickRegion = detectClickRegion(mousePos, windowFrame)

                    print("[Resizer] Starting window resize: " .. windowUnderMouse:title() .. " (region: " .. resizer.clickRegion .. ")")
                    resizer.isResizing = true
                    resizer.resizedWindow = windowUnderMouse
                    resizer.startMousePos = mousePos
                    resizer.startWindowFrame = windowFrame
                    
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
                    resizer.clickRegion = nil

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
