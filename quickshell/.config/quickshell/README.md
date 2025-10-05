# Quickshell Configuration

A minimal monochrome Wayland shell for Hyprland, forked from [Caelestia](https://github.com/caelestia-dots/shell) and extensively refactored for simplicity.

## Features

- **Minimal Design:** Pure monochrome theme (black/white/grey) with Material Design 3 components
- **Full Desktop Environment:** Bar, launcher, dashboard, notifications, OSD, session menu
- **External Wallpaper Management:** Uses `hyprpaper` independently of shell configuration
- **Modular Architecture:** Clean separation between components, config, modules, and services
- **Hot-Reload:** Changes to `shell.json` and `scheme.json` apply instantly

## Documentation

📚 **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Comprehensive architecture documentation:

- Directory structure and how `components/`, `config/`, `modules/`, `services/`, `utils/` interact
- Complete component inventory with usage examples
- Visual ASCII representations of all GUI elements (bar, launcher, dashboard, etc.)
- Configuration file structure (`shell.json`, `scheme.json`)
- Data flow and import structure
- Development workflow and naming conventions

---

## Directory Structure & XDG Paths

This quickshell configuration uses the XDG Base Directory specification to organize files:

### **Config Directory (`~/.config/quickshell/`)**

**Purpose:** User-editable configuration files that define shell appearance and behavior.

**Contains:**

- `shell.json` - Main configuration (bar layout, enabled features, launcher actions, etc.)
- `scheme.json` - Color scheme definitions (currently monochrome theme)
- `*.qml` files - QML source code (symlinked from dotfiles repo via stow)

**Git Versioned:** ✅ Yes - These files are tracked in your dotfiles repo.

---

### **State Directory (`~/.local/state/quickshell/`)**

**Purpose:** Runtime state that persists between sessions but changes during use.

**Contains:**

- `scheme.json` - Color scheme (copied from config, can be edited here)
- `apps.sqlite` - Application launch history for launcher sorting
- `notifs.json` - Notification state/history
- `sequences.txt` - Keyboard sequences/macros
- `wallpaper/` - Current wallpaper state

**Git Versioned:** ❌ No - User-specific runtime data.

---

### **Cache Directory (`~/.cache/quickshell/`)**

**Purpose:** Temporary cached data for performance (safe to delete).

**Contains:**

- `imagecache/` - Processed images for faster loading
- `imagecache/notifs/` - Notification image cache

**Git Versioned:** ❌ No - Temporary performance optimization data.

---

### **Data Directory (`~/.local/share/quickshell/`)**

**Purpose:** Application-specific persistent data (not currently used in minimal config).

**Git Versioned:** ❌ No - User-specific persistent data.

---

## Installation from Dotfiles

### Prerequisites

**Runtime Dependencies:**

- [`quickshell-git`](https://quickshell.outfoxxed.me) - Must be git version (not latest tagged release)
- [`hyprland`](https://hyprland.org) - Wayland compositor
- [`hyprpaper`](https://github.com/hyprwm/hyprpaper) - Wallpaper daemon
- [`brightnessctl`](https://github.com/Hummer12007/brightnessctl) - Brightness control
- [`libcava`](https://github.com/LukashonakV/cava) - Audio visualizer library
- [`networkmanager`](https://networkmanager.dev) - Network management
- [`aubio`](https://github.com/aubio/aubio) - Beat detection for media player
- [`libpipewire`](https://pipewire.org) - Audio system
- `qt6-declarative` - Qt QML runtime
- `qt6-base` - Qt base libraries
- `gcc-libs` - C++ runtime
- `glibc` - C standard library
- [`material-symbols`](https://fonts.google.com/icons) - Icon font
- [`ttf-caskaydia-cove-nerd`](https://www.nerdfonts.com/font-downloads) - Monospace font

**Build Dependencies:**

- [`cmake`](https://cmake.org) - Build system
- [`ninja`](https://github.com/ninja-build/ninja) - Build tool
- `gcc` or `clang` - C++ compiler
- [`libqalculate`](https://github.com/Qalculate/libqalculate) - Calculator library (for QML plugin)

**Optional:**

- [`ddcutil`](https://github.com/rockowitz/ddcutil) - External monitor brightness
- [`lm-sensors`](https://github.com/lm-sensors/lm-sensors) - Temperature monitoring
- [`pavucontrol`](https://freedesktop.org/software/pulseaudio/pavucontrol/) - Audio settings GUI

---

### Installation Steps

#### 1. Clone Your Dotfiles Repository

```sh
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
```

#### 2. Build the C++ QML Plugins

The configuration requires custom QML plugins (for beat detection, audio visualization, Hyprland integration, etc.) that must be compiled and installed system-wide:

```sh
cd ~/dotfiles/quickshell/.config/quickshell

# Build all modules, including QMLLS configuration for IDEs
rm -rf build
cmake -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/ \
  -DVERSION=1.0.0 \
  -DGIT_REVISION=refactored \
  -DENABLE_MODULES="extras;plugin;shell"

# Generate QML metadata for IDEs (includes .qmlls.ini)
cmake --build build

# Install QML plugins system-wide
sudo cmake --install build
```

> [!NOTE]
> The plugins include:
>
> - **QShell** - Core utilities (calculator, app database, image analysis, toast notifications)
> - **QShell.Audio** - Beat tracker, audio collector, Cava visualizer for media visualization
> - **QShell.Hyprland** - Hyprland keyboard state, caching image manager, logind integration
> - **QShell.Models** - Filesystem models for file dialogs
>
> These are installed to `/usr/lib/qt6/qml/QShell/` and imported in QML as `import QShell`, `import QShell.Audio`, etc.

#### 3. Configure Stow to Ignore Build Artifacts

Create a `.stow-local-ignore` file to prevent stow from symlinking build artifacts:

```sh
cd ~/dotfiles/quickshell
cat > .stow-local-ignore << 'EOF'
build
.qmlls.ini
EOF
```

#### 4. Stow the Configuration

Use GNU Stow to symlink the configuration into place:

```sh
cd ~/dotfiles
stow quickshell
```

This creates symlinks:

```
~/.config/quickshell/shell.qml → ~/dotfiles/quickshell/.config/quickshell/shell.qml
~/.config/quickshell/config/ → ~/dotfiles/quickshell/.config/quickshell/config/
~/.config/quickshell/modules/ → ~/dotfiles/quickshell/.config/quickshell/modules/
~/.config/quickshell/services/ → ~/dotfiles/quickshell/.config/quickshell/services/
...
```

> [!IMPORTANT]
> The `build/` directory contains compiled C++ plugins and should **not** be stowed.
> The `.qmlls.ini` file is runtime-generated by quickshell and should **not** be stowed.

#### 5. Set Up Runtime Directories

Create the state directory and copy the initial color scheme:

```sh
mkdir -p ~/.local/state/quickshell
cp ~/dotfiles/quickshell/.config/quickshell/scheme.json ~/.local/state/quickshell/
```

#### 6. Add to Hyprland Config

Add to your `~/.config/hypr/hyprland.conf`:

```conf
# Start wallpaper daemon
exec-once = hyprpaper

# Start quickshell
exec-once = qs -c ~/.config/quickshell
```

Or manually launch for testing:

```sh
qs -c ~/.config/quickshell
```

The `-c` flag tells quickshell to load the configuration from `~/.config/quickshell/shell.qml`.

---

### Understanding the Build Process

When you run `cmake --build build`, the following happens:

1. **Compiles C++ Plugins:** Builds custom QML modules with beat detection, audio visualization, Hyprland integration, and utility functions
2. **Generates QML Module Files:** Creates `qmldir` and type info files for Qt's QML engine
3. **Installs to System Paths:**
   - Plugins: `/usr/lib/qt6/qml/QShell/` (and submodules: `Audio/`, `Hyprland/`, `Models/`)
   - Libraries: `/usr/lib/quickshell/`

The QML files in your dotfiles reference the plugins via `import QShell`, `import QShell.Audio`, etc., which Qt resolves using the installed `qmldir` files.

> [!NOTE]
> **Config files are NOT installed system-wide** - they remain in your dotfiles repo and are symlinked to `~/.config/quickshell/` via stow. This allows you to version control your config and easily make changes.

---

### Environment Variables

You can customize paths using environment variables (set in `.envrc`, shell profile, or systemd service):

- `QUICKSHELL_LIB_DIR` - Override library directory (default: `/usr/lib/quickshell`)
- `QUICKSHELL_RECORDINGS_DIR` - Override recording directory (default: `~/Videos/Recordings`)
- `QUICKSHELL_XKB_RULES_PATH` - Override keyboard layout rules (default: `/usr/share/X11/xkb/rules/base.lst`)

---

## Usage

Start quickshell with:

```sh
qs -c ~/.config/quickshell
```

Or add to your Hyprland config for auto-start:

```conf
exec-once = qs -c ~/.config/quickshell
```

### Shortcuts/IPC

All keybinds are accessible via Hyprland [global shortcuts](https://wiki.hyprland.org/Configuring/Binds/#dbus-global-shortcuts).

You can configure keybinds in your Hyprland config. For example:

```conf
# Toggle launcher
bind = SUPER, SPACE, global, qshell:launcher

# Toggle sidebar (notification center)
bind = SUPER, N, exec, qs ipc call drawers toggle sidebar

# Toggle dashboard
bind = SUPER, D, exec, qs ipc call drawers toggle dashboard
```

All IPC commands can be accessed via `qs ipc call <target> <function> [args]`. For example:

```sh
qs ipc call drawers toggle sidebar
```

The list of IPC commands can be shown via `qs ipc show`:

```
$ qs ipc show
target drawers
  function toggle(drawer: string): void
  function list(): string
target brightness
  function get(): real
  function getFor(query: string): real
  function set(value: string): string
  function setFor(query: string, value: string): string
target toaster
  function info(title: string, message: string, icon: string): void
  function success(title: string, message: string, icon: string): void
  function warn(title: string, message: string, icon: string): void
  function error(title: string, message: string, icon: string): void
target controlCenter
  function open(): void
```

### Wallpapers

Wallpapers are managed by `hyprpaper`. Configure wallpapers in `~/.config/hypr/hyprpaper.conf`:

```conf
preload = ~/Pictures/Wallpapers/wallpaper.jpg
wallpaper = ,~/Pictures/Wallpapers/wallpaper.jpg
```

## Updating

To update the configuration:

```sh
cd ~/dotfiles
git pull
stow -R quickshell  # Re-stow to update symlinks
```

If the QML plugins were updated, rebuild and reinstall:

```sh
cd ~/dotfiles/quickshell/.config/quickshell
rm -rf build
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/ -DVERSION=1.0.0 -DGIT_REVISION=refactored -DENABLE_MODULES="extras;plugin"
cmake --build build
sudo cmake --install build
```

## Configuring

All configuration options are in `~/.config/quickshell/shell.json`. This file is symlinked from your dotfiles repo, so edit it there:

```sh
# Edit the config in your dotfiles repo
vim ~/dotfiles/quickshell/.config/quickshell/shell.json
```

Changes are hot-reloaded automatically when you save the file.

### Example configuration

> [!NOTE]
> The example configuration only includes recommended configuration options. For more advanced customisation
> such as modifying the size of individual items or changing constants in the code, there are some other
> options which can be found in the source files in the `config` directory.

<details><summary>Example</summary>

```json
{
  "appearance": {
    "anim": {
      "durations": {
        "scale": 1
      }
    },
    "font": {
      "family": {
        "material": "Material Symbols Rounded",
        "mono": "CaskaydiaCove NF",
        "sans": "Rubik"
      },
      "size": {
        "scale": 1
      }
    },
    "padding": {
      "scale": 1
    },
    "rounding": {
      "scale": 1
    },
    "spacing": {
      "scale": 1
    },
    "transparency": {
      "enabled": false,
      "base": 0.85,
      "layers": 0.4
    }
  },
  "general": {
    "apps": {
      "terminal": ["foot"],
      "audio": ["pavucontrol"],
      "playback": ["mpv"],
      "explorer": ["thunar"]
    },
    "battery": {
      "warnLevels": [
        {
          "level": 20,
          "title": "Low battery",
          "message": "You might want to plug in a charger",
          "icon": "battery_android_frame_2"
        },
        {
          "level": 10,
          "title": "Did you see the previous message?",
          "message": "You should probably plug in a charger <b>now</b>",
          "icon": "battery_android_frame_1"
        },
        {
          "level": 5,
          "title": "Critical battery level",
          "message": "PLUG THE CHARGER RIGHT NOW!!",
          "icon": "battery_android_alert",
          "critical": true
        }
      ],
      "criticalLevel": 3
    },
    "idle": {
      "lockBeforeSleep": true,
      "inhibitWhenAudio": true,
      "timeouts": [
        {
          "timeout": 180,
          "idleAction": "lock"
        },
        {
          "timeout": 300,
          "idleAction": "dpms off",
          "returnAction": "dpms on"
        },
        {
          "timeout": 600,
          "idleAction": ["systemctl", "suspend-then-hibernate"]
        }
      ]
    }
  },
  "background": {
    "desktopClock": {
      "enabled": false
    },
    "enabled": true,
    "visualiser": {
      "enabled": false,
      "autoHide": true,
      "rounding": 1,
      "spacing": 1
    }
  },
  "bar": {
    "clock": {
      "showIcon": true
    },
    "dragThreshold": 20,
    "entries": [
      {
        "id": "logo",
        "enabled": true
      },
      {
        "id": "workspaces",
        "enabled": true
      },
      {
        "id": "spacer",
        "enabled": true
      },
      {
        "id": "activeWindow",
        "enabled": true
      },
      {
        "id": "spacer",
        "enabled": true
      },
      {
        "id": "tray",
        "enabled": true
      },
      {
        "id": "clock",
        "enabled": true
      },
      {
        "id": "statusIcons",
        "enabled": true
      },
      {
        "id": "power",
        "enabled": true
      }
    ],
    "persistent": true,
    "scrollActions": {
      "brightness": true,
      "workspaces": true,
      "volume": true
    },
    "showOnHover": true,
    "status": {
      "showAudio": false,
      "showBattery": true,
      "showBluetooth": true,
      "showKbLayout": false,
      "showMicrophone": false,
      "showNetwork": true,
      "showLockStatus": true
    },
    "tray": {
      "background": false,
      "compact": false,
      "iconSubs": [],
      "recolour": false
    },
    "workspaces": {
      "activeIndicator": true,
      "activeLabel": "󰮯",
      "activeTrail": false,
      "label": "  ",
      "occupiedBg": false,
      "occupiedLabel": "󰮯",
      "perMonitorWorkspaces": true,
      "showWindows": true,
      "shown": 5
    }
  },
  "border": {
    "rounding": 25,
    "thickness": 10
  },
  "dashboard": {
    "enabled": true,
    "dragThreshold": 50,
    "mediaUpdateInterval": 500,
    "showOnHover": true
  },
  "launcher": {
    "actionPrefix": ">",
    "actions": [
      {
        "name": "Calculator",
        "icon": "calculate",
        "description": "Do simple math equations (powered by Qalc)",
        "command": ["autocomplete", "calc"],
        "enabled": true,
        "dangerous": false
      },
      {
        "name": "Scheme",
        "icon": "palette",
        "description": "Change the current colour scheme",
        "command": ["autocomplete", "scheme"],
        "enabled": true,
        "dangerous": false
      },
      {
        "name": "Wallpaper",
        "icon": "image",
        "description": "Change the current wallpaper",
        "command": ["autocomplete", "wallpaper"],
        "enabled": true,
        "dangerous": false
      },
      {
        "name": "Variant",
        "icon": "colors",
        "description": "Change the current scheme variant",
        "command": ["autocomplete", "variant"],
        "enabled": true,
        "dangerous": false
      },
      {
        "name": "Transparency",
        "icon": "opacity",
        "description": "Change shell transparency",
        "command": ["autocomplete", "transparency"],
        "enabled": false,
        "dangerous": false
      },
      {
        "name": "Random",
        "icon": "casino",
        "description": "Switch to a random wallpaper (disabled - using hyprpaper)",
        "command": [],
        "enabled": false,
        "dangerous": false
      },
      {
        "name": "Light",
        "icon": "light_mode",
        "description": "Change the scheme to light mode",
        "command": ["setMode", "light"],
        "enabled": true,
        "dangerous": false
      },
      {
        "name": "Dark",
        "icon": "dark_mode",
        "description": "Change the scheme to dark mode",
        "command": ["setMode", "dark"],
        "enabled": true,
        "dangerous": false
      },
      {
        "name": "Shutdown",
        "icon": "power_settings_new",
        "description": "Shutdown the system",
        "command": ["systemctl", "poweroff"],
        "enabled": true,
        "dangerous": true
      },
      {
        "name": "Reboot",
        "icon": "cached",
        "description": "Reboot the system",
        "command": ["systemctl", "reboot"],
        "enabled": true,
        "dangerous": true
      },
      {
        "name": "Logout",
        "icon": "exit_to_app",
        "description": "Log out of the current session",
        "command": ["loginctl", "terminate-user", ""],
        "enabled": true,
        "dangerous": true
      },
      {
        "name": "Lock",
        "icon": "lock",
        "description": "Lock the current session",
        "command": ["loginctl", "lock-session"],
        "enabled": true,
        "dangerous": false
      },
      {
        "name": "Sleep",
        "icon": "bedtime",
        "description": "Suspend then hibernate",
        "command": ["systemctl", "suspend-then-hibernate"],
        "enabled": true,
        "dangerous": false
      }
    ],
    "dragThreshold": 50,
    "vimKeybinds": false,
    "enableDangerousActions": false,
    "maxShown": 7,
    "specialPrefix": "@",
    "useFuzzy": {
      "apps": false,
      "actions": false,
      "schemes": false,
      "variants": false,
      "wallpapers": false
    },
    "showOnHover": false,
    "hiddenApps": []
  },
  "lock": {
    "recolourLogo": false
  },
  "notifs": {
    "actionOnClick": false,
    "clearThreshold": 0.3,
    "defaultExpireTimeout": 5000,
    "expandThreshold": 20,
    "expire": false
  },
  "osd": {
    "enabled": true,
    "enableBrightness": true,
    "enableMicrophone": false,
    "hideDelay": 2000
  },
  "paths": {
    "mediaGif": "root:/assets/bongocat.gif",
    "sessionGif": "root:/assets/kurukuru.gif",
    "wallpaperDir": "~/Pictures/Wallpapers"
  },
  "services": {
    "audioIncrement": 0.1,
    "defaultPlayer": "Spotify",
    "gpuType": "",
    "playerAliases": [
      { "from": "com.github.th_ch.youtube_music", "to": "YT Music" }
    ],
    "weatherLocation": "",
    "useFahrenheit": false,
    "useTwelveHourClock": false,
    "smartScheme": true,
    "visualiserBars": 45
  },
  "session": {
    "dragThreshold": 30,
    "enabled": true,
    "vimKeybinds": false,
    "commands": {
      "logout": ["loginctl", "terminate-user", ""],
      "shutdown": ["systemctl", "poweroff"],
      "hibernate": ["systemctl", "hibernate"],
      "reboot": ["systemctl", "reboot"]
    }
  },
  "sidebar": {
    "dragThreshold": 80,
    "enabled": true
  },
  "utilities": {
    "enabled": true,
    "maxToasts": 4,
    "toasts": {
      "audioInputChanged": true,
      "audioOutputChanged": true,
      "capsLockChanged": true,
      "chargingChanged": true,
      "configLoaded": true,
      "dndChanged": true,
      "gameModeChanged": true,
      "numLockChanged": true
    }
  }
}
```

</details>

## FAQ

### My screen is flickering!

Try disabling VRR in your Hyprland config (`~/.config/hypr/hyprland.conf`):

```conf
misc {
    vrr = 0
}
```

### How do I customize the color scheme?

Edit `~/.local/state/quickshell/scheme.json` to change colors. The config uses a monochrome Material Design 3 theme by default.

### How do I enable/disable features?

Edit `~/dotfiles/quickshell/.config/quickshell/shell.json` to toggle features:

```json
{
  "sidebar": { "enabled": true },
  "dashboard": { "enabled": true },
  "osd": { "enabled": true }
}
```

### QML imports are broken / "module not installed" error

Rebuild and reinstall the QML plugins:

```sh
cd ~/dotfiles/quickshell/.config/quickshell
rm -rf build
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/ -DVERSION=1.0.0 -DGIT_REVISION=refactored -DENABLE_MODULES="extras;plugin"
cmake --build build
sudo cmake --install build
```

## Credits

This configuration is a refactored version of [Caelestia](https://github.com/caelestia-dots/shell), modified for personal use with:

- Minimal monochrome theme
- Hyprpaper integration
- Dotfiles-friendly installation via GNU Stow

Thanks to:

- [@outfoxxed](https://github.com/outfoxxed) for creating Quickshell
- [Caelestia](https://github.com/caelestia-dots/shell) for the original configuration
