# Machine-Specific Hyprland Configuration

This directory contains machine-specific configuration templates. This allows you to maintain a single dotfiles repository that works across multiple machines with different monitor setups.

Since Hyprland 0.55, Hyprland itself is configured in Lua (`hyprland.lua`), while hyprlock and hyprpaper still use the hyprlang `.conf` format. Each machine therefore has **two** template files:

- `machines/<machine>.lua` — monitors and workspace assignments, loaded by `hyprland.lua`
- `machines/<machine>.conf` — monitor names and wallpaper paths, sourced by `hyprlock.conf` and `hyprpaper.conf`

## Setup

### First-time setup on a new machine:

1. **Choose your machine config:**
   ```bash
   cd ~/.config/hypr
   cp machines/laptop.lua local.lua && cp machines/laptop.conf local.conf    # For laptop
   # OR
   cp machines/desktop.lua local.lua && cp machines/desktop.conf local.conf  # For desktop
   ```

2. **Edit `local.lua` and `local.conf` to match your hardware:**
   - Update monitor names (run `hyprctl monitors` to see yours)
   - Adjust resolutions and refresh rates
   - Set scaling factors
   - Configure wallpaper paths

3. **Reload Hyprland:**
   ```bash
   hyprctl reload
   ```

## How it works

- `hyprland.lua` does `pcall(require, "local")` at the top, which loads `local.lua` with your machine's `hl.monitor()` and `hl.workspace_rule()` calls.
- `hyprlock.conf` and `hyprpaper.conf` source `local.conf` at the top, which defines machine-specific variables:
  - `$primary_monitor` / `$secondary_monitor` - Monitor names
  - `$lock_primary_monitor` / `$lock_secondary_monitor` - Monitors for lock screen UI
  - `$wallpaper_primary` / `$wallpaper_secondary` - Wallpaper paths

## Adding a new machine

1. Copy an existing machine config pair as a template:
   ```bash
   cp machines/laptop.lua machines/my-machine.lua
   cp machines/laptop.conf machines/my-machine.conf
   ```

2. Edit them with your machine's settings

3. Commit them to the repository:
   ```bash
   git add machines/my-machine.lua machines/my-machine.conf
   git commit -m "Add config for my-machine"
   ```

4. On your machine, copy them to `local.lua` / `local.conf`:
   ```bash
   cp machines/my-machine.lua local.lua
   cp machines/my-machine.conf local.conf
   ```

## Finding your monitor names

```bash
hyprctl monitors
```

Look for the monitor identifier (e.g., `eDP-1`, `DP-4`, `HDMI-A-2`)

## Git tracking

- `local.lua` and `local.conf` are gitignored (machine-specific, not tracked)
- `machines/*` are tracked (templates for different setups)
- Your main configs are tracked and work across all machines
