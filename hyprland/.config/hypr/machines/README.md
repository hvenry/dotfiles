# Machine-Specific Hyprland Configuration

This directory contains machine-specific configuration templates for Hyprland. This allows you to maintain a single dotfiles repository that works across multiple machines with different monitor setups.

## Setup

### First-time setup on a new machine:

1. **Choose your machine config:**
   ```bash
   cd ~/.config/hypr
   cp machines/laptop.conf local.conf    # For laptop
   # OR
   cp machines/desktop.conf local.conf   # For desktop
   ```

2. **Edit `local.conf` to match your hardware:**
   - Update monitor names (run `hyprctl monitors` to see yours)
   - Adjust resolutions and refresh rates
   - Set scaling factors
   - Configure wallpaper paths

3. **Reload Hyprland:**
   ```bash
   hyprctl reload
   ```

## How it works

The main Hyprland configuration files (`hyprland.conf`, `hyprlock.conf`, `hyprpaper.conf`) source `local.conf` at the top, which loads machine-specific variables:

- `$primary_monitor` - Primary monitor name
- `$primary_resolution` - Primary monitor resolution
- `$primary_scale` - Primary monitor scaling
- `$lock_primary_monitor` - Monitor for lock screen UI
- `$wallpaper_primary` - Primary wallpaper path
- And more...

## Adding a new machine

1. Copy an existing machine config as a template:
   ```bash
   cp machines/laptop.conf machines/my-machine.conf
   ```

2. Edit `my-machine.conf` with your machine's settings

3. Commit it to the repository:
   ```bash
   git add machines/my-machine.conf
   git commit -m "Add config for my-machine"
   ```

4. On your machine, copy it to `local.conf`:
   ```bash
   cp machines/my-machine.conf local.conf
   ```

## Finding your monitor names

```bash
hyprctl monitors
```

Look for the monitor identifier (e.g., `eDP-1`, `DP-4`, `HDMI-A-2`)

## Git tracking

- `local.conf` is gitignored (machine-specific, not tracked)
- `machines/*.conf` are tracked (templates for different setups)
- Your main configs are tracked and work across all machines
