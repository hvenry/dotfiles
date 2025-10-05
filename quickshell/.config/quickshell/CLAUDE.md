# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a customized Quickshell configuration for Hyprland, originally forked from [Caelestia](https://github.com/caelestia-dots/shell). It has been extensively refactored into a minimal monochrome overlay system that provides GUI elements (bar, launcher, menus, OSD) while letting hyprpaper manage wallpapers independently.

The configuration is part of a larger dotfiles repository managed with GNU Stow, located at `/home/hvenry/dotfiles/quickshell/.config/quickshell/`.

## Architecture

### QML Module System

Quickshell uses Qt's QML declarative language with a modular import system:

- **`shell.qml`** - Entry point that imports and instantiates top-level modules
- **`modules/`** - High-level feature modules (bar, launcher, dashboard, etc.)
- **`services/`** - Singleton services providing global state/functionality (Hypr, Brightness, Audio, etc.)
- **`components/`** - Reusable UI components (buttons, text fields, animations, etc.)
- **`config/`** - Configuration system that reads `shell.json` and provides typed config objects
- **`utils/`** - Utility singletons (Paths, Icons, etc.)

### C++ QML Plugin System

The configuration requires custom C++ QML plugins that are compiled and installed system-wide:

**Plugin Structure:**

- **`plugin/`** - Custom QML modules (beat tracker, audio collector, Cava visualizer)
- **`extras/`** - Additional QML modules (Hyprland extras, logind integration, image utilities)

**Build System:**

- Uses CMake with Ninja generator
- Installs to `/usr/lib/qt6/qml/Caelestia/` for QML imports
- Installs libraries to `/usr/lib/quickshell/`

**QML Imports:**

```qml
import Caelestia             // Plugin modules (beat tracker, audio, Cava)
import Caelestia.Internal    // Extras (caching image manager, Hyprland extras)
import Caelestia.Models      // Filesystem models
```

### Configuration System

**Two-tier configuration:**

1. **`~/.config/quickshell/shell.json`** (or `~/.config/caelestia/shell.json`)
   - User-editable settings (bar layout, enabled features, launcher actions, etc.)
   - Read by `config/Config.qml` via `JsonAdapter`
   - Hot-reloaded on file changes

2. **`~/.local/state/quickshell/scheme.json`**
   - Color scheme definitions (Material Design 3 colors)
   - Read by `services/Colours.qml`
   - Currently uses pure monochrome theme (black/white/grey)

### Service Singletons

Key services accessible globally via QML imports:

- **`Hypr`** (`services/Hypr.qml`) - Hyprland integration (workspaces, windows, monitors)
- **`Brightness`** (`services/Brightness.qml`) - Display brightness control (ddcutil, brightnessctl, asdbctl)
- **`Config`** (`config/Config.qml`) - Configuration loader and hot-reloader
- **`Paths`** (`utils/Paths.qml`) - XDG directory paths and environment variables
- **`Colours`** (`services/Colours.qml`) - Dynamic color scheme management

### Directory Structure (XDG Paths)

**Config:** `~/.config/quickshell/` (versioned in dotfiles)

- `shell.json` - Main configuration
- `scheme.json` - Color scheme (if stored here)
- `*.qml` files - QML source code (symlinked via stow)

**State:** `~/.local/state/quickshell/` (runtime state, not versioned)

- `apps.sqlite` - Application launch history
- `notifs.json` - Notification state
- `scheme.json` - Color scheme (if stored here)

**Cache:** `~/.cache/quickshell/` (temporary, safe to delete)

- `imagecache/` - Processed images for faster loading

**Data:** `~/.local/share/quickshell/` (persistent data, not currently used)

All paths are centralized in `utils/Paths.qml` and respect XDG environment variables.

## Common Development Commands

### Build and Install

```bash
cd ~/dotfiles/quickshell/.config/quickshell

# Development build (with debug symbols)
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_CXX_COMPILER=clazy -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DDISTRIBUTOR=direnv
cmake --build build
export QUICKSHELL_LIB_DIR="$PWD/build/lib"
export QML2_IMPORT_PATH="$PWD/build/qml:${QML2_IMPORT_PATH:-}"

# Production build
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/
cmake --build build
sudo cmake --install build
```

### Launch Quickshell

```bash
# From dotfiles repo (after stowing)
qs -c ~/.config/quickshell

# Auto-start via Hyprland (add to ~/.config/hypr/hyprland.conf)
exec-once = hyprpaper
exec-once = qs -c ~/.config/quickshell
```

### Stow Configuration

```bash
cd ~/dotfiles
stow quickshell  # Creates symlinks in ~/.config/quickshell/
stow -D quickshell  # Removes symlinks
```

### Monitor Brightness Control

```bash
# Test brightness (requires i2c group membership)
ddcutil --sleep-multiplier 0.5 detect --brief
ddcutil --sleep-multiplier 0.5 -d 1 getvcp 10
ddcutil --sleep-multiplier 0.5 -d 1 setvcp 10 50

# Set up i2c permissions
sudo usermod -aG i2c $USER
echo 'KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"' | sudo tee /etc/udev/rules.d/45-ddcutil-i2c.rules
# Reboot required for udev rules
```

## Important Implementation Details

### Brightness Control Architecture

**File:** `services/Brightness.qml`

**Multi-backend system:**

1. **ddcutil** - External monitors via DDC/CI (requires i2c permissions)
2. **brightnessctl** - Laptop built-in displays via Linux backlight
3. **asdbctl** - Apple Studio Display (if detected)

**Key logic:**

- Detects monitors via `ddcutil detect --brief` on startup
- Parses DRM connector names (handles both `DRM connector:` and `DRM_connector:` formats)
- Maps monitors to I2C bus numbers for ddcutil control
- Uses `--sleep-multiplier 0.5` for faster DDC/CI commands
- Queues brightness changes to avoid DDC/CI rate limiting (500ms timer)

**Important:** The regex at line 83 handles multiple DDC output formats:

```qml
const connectorMatch = d.match(/DRM[_ ]connector:\s+(.*)/);
```

### Monitor Detection and Querying

**File:** `services/Brightness.qml`

**Query system:**

```qml
function getMonitor(query: string): var {
    if (query === "active") // Currently focused monitor
    if (query.startsWith("model:")) // By model name
    if (query.startsWith("serial:")) // By serial number
    if (query.startsWith("id:")) // By Hyprland monitor ID
    // Otherwise by connector name (e.g., "DP-1")
}
```

### Hyprland Integration

**File:** `services/Hypr.qml`

**Uses Caelestia.HyprExtras QML module for:**

- Keyboard state (Caps Lock, Num Lock)
- Active keymap detection
- Device management

**Key properties:**

- `toplevels` - All windows
- `workspaces` - All workspaces
- `monitors` - All displays
- `activeToplevel` - Currently focused window
- `focusedWorkspace` - Currently active workspace
- `keyboard` - Main keyboard device

**Event handling:**

- Listens to `Hyprland.rawEvent` signals
- Refreshes state based on event types (workspace changes, window events, etc.)

### Configuration Hot-Reloading

**File:** `config/Config.qml`

**Mechanism:**

- `FileView` watches `${Paths.config}/shell.json`
- On file change: triggers `reload()`, parses JSON, shows toast notification
- `JsonAdapter` automatically maps JSON to typed QML config objects
- All modules bind to `Config.*` properties reactively

**Usage:**

```qml
import qs.config

// In any QML file
Config.bar.persistent  // Reads from shell.json → bar.persistent
Config.dashboard.enabled  // Reads from shell.json → dashboard.enabled
```

### Color Scheme System

**File:** `services/Colours.qml`

**Current state:**

- Pure monochrome scheme (no hue, only lightness)
- Reads from `~/.local/state/quickshell/scheme.json`
- Material Design 3 color tokens (surface, primary, onPrimary, etc.)
- CLI-based color extraction disabled (requires `caelestia-cli`)

**To change colors:** Edit `scheme.json` directly - changes reload automatically.

## Key Files and Their Purposes

### Entry Points

- **`shell.qml`** - Main entry point, instantiates top-level modules (Drawers, Shortcuts)

### Core Services

- **`services/Hypr.qml`** - Hyprland state (workspaces, windows, monitors, keyboard)
- **`services/Brightness.qml`** - Multi-backend brightness control (ddcutil, brightnessctl, asdbctl)
- **`services/Colours.qml`** - Color scheme management
- **`services/Audio.qml`** - Audio input/output control via PipeWire
- **`services/Network.qml`** - NetworkManager integration
- **`services/Bluetooth.qml`** - BlueZ integration
- **`services/Mpris.qml`** - Media player control (MPRIS2)

### Configuration

- **`config/Config.qml`** - Main config loader with hot-reloading
- **`utils/Paths.qml`** - Centralized path management (XDG directories, environment variables)

### Build System

- **`CMakeLists.txt`** - Top-level build configuration
- **`.envrc`** - direnv configuration for development builds
- **`plugin/CMakeLists.txt`** - C++ QML plugin build
- **`extras/CMakeLists.txt`** - C++ extras build

### Module Organization

**Active modules (enabled in shell.qml):**

- `modules/drawers/` - Contains bar, launcher, dashboard, panels
- `modules/Shortcuts.qml` - IPC handlers for keybinds

**Disabled modules (removed from shell.qml):**

- `modules/lock/` - Lock screen (disabled in minimal config)
- `modules/areapicker/` - Screenshot area picker (disabled)

## Refactor History

See `REFACTOR_CHECKPOINT.md` for detailed changelog of the minimal monochrome refactor:

- Removed Caelestia branding, renamed paths from `caelestia` to `quickshell`
- Disabled heavy features (background management, lock screen, utilities)
- Removed `caelestia-cli` dependency, uses hyprpaper directly
- Implemented pure monochrome color scheme
- Fixed brightness control bugs (DRM connector regex, ddcutil timing)

## Environment Variables

**Development:**

- `QUICKSHELL_LIB_DIR` - Override library directory (default: `/usr/lib/quickshell`)
- `QML2_IMPORT_PATH` - Additional QML import paths (set by `.envrc` for dev builds)

**Runtime:**

- `QUICKSHELL_RECORDINGS_DIR` - Override recording directory
- `QUICKSHELL_XKB_RULES_PATH` - Override keyboard layout rules path

## Dependencies

**Runtime (required):**

- `quickshell-git` - QML shell framework (must be git version)
- `hyprland` - Wayland compositor
- `hyprpaper` - Wallpaper daemon
- `brightnessctl` - Laptop brightness control
- `networkmanager` - Network management
- `pipewire` - Audio system
- `aubio` - Beat detection for media player
- `libcava` - Audio visualizer library
- `qt6-declarative`, `qt6-base` - Qt runtime

**Build (required):**

- `cmake`, `ninja` - Build system
- `gcc` or `clang` - C++ compiler
- `libqalculate` - Calculator library (for QML plugin)

**Optional:**

- `ddcutil` - External monitor brightness control
- `lm-sensors` - Temperature monitoring
- `pavucontrol` - Audio settings GUI

## Debugging Tips

### Check QML Import Paths

```bash
echo $QML2_IMPORT_PATH
# Should include build/qml for dev builds
```

### Monitor Brightness Issues

- Verify i2c group membership: `groups | grep i2c`
- Test ddcutil: `sudo ddcutil detect`
- Check udev rules: `cat /etc/udev/rules.d/45-ddcutil-i2c.rules`

### Configuration Not Loading

- Check file exists: `cat ~/.config/quickshell/shell.json`
- Verify JSON syntax: `jq . ~/.config/quickshell/shell.json`
- Watch quickshell output for parse errors

### Color Scheme Issues

- Check scheme file: `cat ~/.local/state/quickshell/scheme.json`
- Verify all required color tokens are present (see `services/Colours.qml`)
