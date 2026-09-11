-- Hyprland configuration (Lua, Hyprland >= 0.55)
-- https://wiki.hypr.land/Configuring/

-- SOURCE MACHINE-SPECIFIC CONFIGURATION
-- Copy one of the configs from machines/ to local.lua:
--   cp machines/laptop.lua local.lua
--   cp machines/desktop.lua local.lua
-- (hyprlock/hyprpaper still read their machine settings from local.conf)
pcall(require, "local")

-- MONITOR CONFIGURATION
-- Monitor and workspace settings are loaded from local.lua required above

-- Fallback for additional monitors
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Autostart
hl.on("hyprland.start", function()
  -- Waybar
  hl.exec_cmd("~/.config/waybar/launch.sh")

  -- Notifications
  hl.exec_cmd("mako")

  -- Wallpaper & idle
  hl.exec_cmd("hyprpaper & hypridle")

  -- Clipboard history
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")

  -- Polkit authentication agent
  hl.exec_cmd("systemctl --user start hyprpolkitagent")

  -- dpi fix
  hl.exec_cmd("xrdb -merge ~/.Xresources")
end)

-- Theming (top-level, so it re-runs on every config reload)
hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"')
hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')

-- NVIDIA stuff
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- Cursor settings
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")

-- SETTINGS
hl.config({
  general = {
    gaps_in = 6,
    gaps_out = 16,
    border_size = 1,
    col = {
      inactive_border = 0xff000000,
      active_border = 0xff141414,
    },
    resize_on_border = true,
  },

  decoration = {
    rounding = 0,
    inactive_opacity = 0.95,
    dim_inactive = true,
    dim_strength = 0.05,
    blur = {
      enabled = true,
      size = 3,
      passes = 3,
    },
    shadow = {
      enabled = true,
      range = 0,
    },
  },

  input = {
    kb_layout = "us",
    kb_options = "ctrl:nocaps",
    repeat_delay = 250,
    repeat_rate = 50,
    follow_mouse = 1,
    natural_scroll = false,
    accel_profile = "flat",
    touchpad = {
      natural_scroll = true,
      -- Scroll speed multiplier: 1.0 is the libinput default, lower is slower.
      -- Tune live without editing this file (note: `hyprctl keyword` does NOT
      -- work with the Lua config - it needs `eval`):
      --   hyprctl eval 'hl.config({ input = { touchpad = { scroll_factor = 0.2 } } })'
      -- The mouse/wheel equivalent is input.scroll_factor, left at the default.
      scroll_factor = 0.25,
    },
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    disable_autoreload = false,
    mouse_move_focuses_monitor = true,
    background_color = 0x00000000,
    font_family = "JetBrainsMono Nerd Font",
  },

  cursor = {
    inactive_timeout = 5,
    persistent_warps = true,
    zoom_factor = 1,
  },

  animations = {
    enabled = true,
  },

  ecosystem = {
    no_donation_nag = true, -- sorry
  },

  xwayland = {
    enabled = true,
    force_zero_scaling = true,
  },

  -- debug = {
  --   overlay = true,
  -- },
})

-- ANIMATIONS
hl.curve("myCurve", { type = "bezier", points = { { 0.4, 0.7 }, { 0.4, 1.0 } } })
hl.animation({ leaf = "windows",    enabled = true, speed = 2, bezier = "myCurve" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 2, bezier = "default" })

-- KEYBINDS
local terminal    = "ghostty"
local menu        = "rofi -show drun"
local fileManager = "thunar"

local mod = "SUPER"

-- Application specific
hl.bind(mod .. " + t", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + escape", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + e", hl.dsp.exec_cmd(fileManager))
hl.bind(mod .. " + p", hl.dsp.exec_cmd("hyprpicker --autocopy"))
hl.bind(mod .. " + V", hl.dsp.exec_cmd([[bash -c 'selected=$(cliphist list | rofi -dmenu -p "Clipboard") && echo "$selected" | cliphist decode | wl-copy']]))

-- Screenshots
hl.bind(mod .. " + S", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m window"))

hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + Tab", hl.dsp.focus({ monitor = "+1" }))
hl.bind(mod .. " + f", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- window management
hl.bind(mod .. " + Return", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))

-- Rearrange windows
hl.bind(mod .. " + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + down",  hl.dsp.window.move({ direction = "down" }))

-- workspaces 1-5 / move window to workspace 1-5
for i = 1, 5 do
  hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- blur configuration
hl.layer_rule({ match = { namespace = "waybar" }, blur = true, blur_popups = true })
hl.layer_rule({ match = { namespace = "rofi" }, blur = true, ignore_alpha = 0.3, no_anim = true, blur_popups = true })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0.3, no_anim = true, blur_popups = true })
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true, ignore_alpha = 0, animation = "fade", xray = false })
hl.layer_rule({ match = { namespace = "swaync" }, blur = true, ignore_alpha = 0.3, no_anim = true })
hl.layer_rule({ match = { namespace = "gtk-layer-shell" }, blur = true, ignore_alpha = 0.3, no_anim = true })

-- thunar always floats
hl.window_rule({
  match = { class = "^(Thunar)$" },
  float = true,
  center = true,
  size = { 900, 600 },
})

-- floating window blur (opacity lets blur show through)
hl.window_rule({ match = { float = true }, opacity = "0.9 0.85" })
hl.window_rule({ match = { class = [[^(com\.mitchellh\.ghostty)$]], float = true }, opacity = "0.7 0.7" })
