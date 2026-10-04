# Hyprland desktop

How the Wayland desktop packages fit together, and how one config serves machines with different monitors.

## Why

The laptop and desktop share keybinds, theming and apps but differ in monitor names, resolutions and wallpapers.
Per-machine values in untracked local files keep one shared config working on both.

## How it works

- `hyprland.lua` does `pcall(require, "local")`, loading `hypr/local.lua` for monitors and workspace rules.
- `hyprlock.conf` and `hyprpaper.conf` source `hypr/local.conf` for monitor and wallpaper variables.
- `waybar/launch.sh` reads `PRIMARY_MONITOR` from `waybar/.local`.
- All three local files are gitignored and seeded by `install-profile.sh` from `hypr/machines/<machine>.{lua,conf}`:
  - It uses a template named after the hostname, else `laptop` if a battery or laptop chassis is found, else `desktop`.
  - `PRIMARY_MONITOR` comes from `local primary` in the machine template, else the first `hyprctl monitors` entry.
- Other packages: Rofi (launcher), Mako (notifications), wlogout (power menu), Ly (display manager), GTK and xsettingsd (theming), xdg (`mimeapps.list`), scripts (Waybar helpers), backgrounds.

## Tech

- Hyprland (Lua config), hyprlock, hypridle, hyprpaper, Waybar, Rofi, Mako, wlogout, Ly.

## Key files

- `linux/hyprland/.config/hypr/hyprland.lua` - main Hyprland config
- `linux/hyprland/.config/hypr/machines/` - per-machine templates, with their own README
- `linux/waybar/.config/waybar/launch.sh` - starts Waybar on the primary monitor
- `linux/waybar/.config/waybar/.local.example` - format of the local Waybar file
- `linux/scripts/.config/scripts/` - battery, network, song and user scripts for Waybar

## Decisions and gotchas

- Hyprland itself is configured in Lua, but hyprlock and hyprpaper still use hyprlang `.conf`, hence two templates per machine.
- `hyprctl reload` cannot switch config formats; a session started on the old `.conf` setup needs a logout.
  Check with `hyprctl systeminfo | grep configProvider`.
- Seeding never overwrites an existing local file; check monitor names against `hyprctl monitors` after the first boot.
- Adding a machine: commit a new `machines/<name>.lua` and `.conf` pair.

## Related

- [Arch setup](arch-setup.md)
- [Install profiles](install-profiles.md)
