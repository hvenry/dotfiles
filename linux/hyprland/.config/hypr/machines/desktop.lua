-- Machine: Desktop
-- Machine-specific Hyprland settings (monitors + workspace assignments).
-- hyprlock/hyprpaper still read their machine settings from local.conf
-- (copy machines/desktop.conf alongside this file, see README.md)

-- Monitor Configuration
local primary = "DP-4"

hl.monitor({ output = primary, mode = "3840x2160@144", position = "0x0", scale = 1.5 })

-- Uncomment if you have a secondary monitor
-- local secondary = "HDMI-A-1"
-- hl.monitor({ output = secondary, mode = "1920x1080@60", position = "2560x0", scale = 1 })

-- Workspace assignments
hl.workspace_rule({ workspace = "1", monitor = primary })
hl.workspace_rule({ workspace = "2", monitor = primary })
hl.workspace_rule({ workspace = "3", monitor = primary })
hl.workspace_rule({ workspace = "4", monitor = primary })
hl.workspace_rule({ workspace = "5", monitor = primary })

-- Uncomment if you have a secondary monitor
-- hl.workspace_rule({ workspace = "9", monitor = secondary })
