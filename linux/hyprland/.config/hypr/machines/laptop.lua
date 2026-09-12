-- Machine: Laptop
-- Machine-specific Hyprland settings (monitors + workspace assignments).
-- hyprlock/hyprpaper still read their machine settings from local.conf
-- (copy machines/laptop.conf alongside this file, see README.md)

-- Monitor Configuration
local primary = "eDP-1"
local secondary = "HDMI-A-2"

hl.monitor({ output = primary, mode = "1920x1080@144", position = "0x0", scale = 1 })
hl.monitor({ output = secondary, mode = "1920x1080@240", position = "2560x0", scale = 1, transform = 1 })

-- Workspace assignments
hl.workspace_rule({ workspace = "1", monitor = primary })
hl.workspace_rule({ workspace = "2", monitor = primary })
hl.workspace_rule({ workspace = "3", monitor = primary })
hl.workspace_rule({ workspace = "4", monitor = primary })
hl.workspace_rule({ workspace = "9", monitor = secondary })

-- Touchpad pointer tuning
hl.device({
	name = "1a582012:00-06cb:cd73-touchpad",
	accel_profile = "adaptive",
	sensitivity = 0.15,
})
