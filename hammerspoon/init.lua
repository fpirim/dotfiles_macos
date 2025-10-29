-- Hammerspoon Configuration
-- Main init.lua file
-- This loads both window mover and window resizer scripts

-- Load the window mover script (Cmd + Left Click)
require("window-mover")

-- Load the window resizer script (Opt + Cmd + Left Click)
require("window-resizer")

-- Show notification that everything is loaded
hs.notify.new({
    title="Hammerspoon",
    informativeText="Window Manager Loaded!\n• Cmd + Click = Move\n• Opt + Cmd + Click = Resize"
}):send()

print("========================================")
print("Hammerspoon Window Manager initialized")
print("• Cmd + Left Click = Move window")
print("• Opt + Cmd + Left Click = Resize window")
print("========================================")
