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

#### 2. Build the C++ QML Plugin

The configuration requires a custom QML plugin (for beat detection, audio visualization, etc.) that must be compiled:

```sh
cd ~/dotfiles/quickshell/.config/quickshell

# Build the plugin
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/
cmake --build build

# Install the plugin (requires sudo)
sudo cmake --install build
```

> [!NOTE]
> The plugin includes:
>
> - **Caelestia.Services** - Beat tracker, audio collector, Cava visualizer
> - **Caelestia.Internal** - Caching image manager, Hyprland extras, logind integration
> - **Caelestia.Models** - Filesystem models
> - **CUtils** - Utility functions (file conversion, image analysis, etc.)

#### 3. Stow the Configuration

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
...
```

#### 4. Add to Hyprland Config

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

1. **Compiles C++ Plugin:** Builds the custom QML module with beat detection, audio visualization, and utility functions
2. **Generates QML Module Files:** Creates `qmldir` and type info files for Qt's QML engine
3. **Installs to System Paths:**
   - Plugin: `/usr/lib/qt6/qml/Caelestia/` (or custom `INSTALL_QMLDIR`)
   - Libraries: `/usr/lib/quickshell/` (or custom `INSTALL_LIBDIR`)

The QML files in your dotfiles reference the plugin via `import Caelestia`, which Qt resolves using the installed `qmldir` files.

---

### Environment Variables

You can customize paths using environment variables (set in `.envrc`, shell profile, or systemd service):

- `QUICKSHELL_LIB_DIR` - Override library directory (default: `/usr/lib/quickshell`)
- `QUICKSHELL_WALLPAPERS_DIR` - Override wallpaper directory (default: from `shell.json` or `~/Pictures`)
- `QUICKSHELL_RECORDINGS_DIR` - Override recording directory (default: `~/Videos/Recordings`)
- `QUICKSHELL_XKB_RULES_PATH` - Override keyboard layout rules (default: `/usr/share/X11/xkb/rules/base.lst`)

---

## Installation (Standalone)

### Arch linux

Dependencies:

- [`caelestia-cli`](https://github.com/caelestia-dots/cli)
- [`quickshell-git`](https://quickshell.outfoxxed.me) - this has to be the git version, not the latest tagged version
- [`ddcutil`](https://github.com/rockowitz/ddcutil)
- [`brightnessctl`](https://github.com/Hummer12007/brightnessctl)
- [`app2unit`](https://github.com/Vladimir-csp/app2unit)
- [`libcava`](https://github.com/LukashonakV/cava)
- [`networkmanager`](https://networkmanager.dev)
- [`lm-sensors`](https://github.com/lm-sensors/lm-sensors)
- [`fish`](https://github.com/fish-shell/fish-shell)
- [`aubio`](https://github.com/aubio/aubio)
- [`libpipewire`](https://pipewire.org)
- `glibc`
- `qt6-declarative`
- `gcc-libs`
- [`material-symbols`](https://fonts.google.com/icons)
- [`caskaydia-cove-nerd`](https://www.nerdfonts.com/font-downloads)
- [`swappy`](https://github.com/jtheoof/swappy)
- [`libqalculate`](https://github.com/Qalculate/libqalculate)
- [`bash`](https://www.gnu.org/software/bash)
- `qt6-base`
- `qt6-declarative`

Build dependencies:

- [`cmake`](https://cmake.org)
- [`ninja`](https://github.com/ninja-build/ninja)

To install the shell manually, install all dependencies and clone this repo to `$XDG_CONFIG_HOME/quickshell/caelestia`.
Then simply build and install using `cmake`.

```sh
cd $XDG_CONFIG_HOME/quickshell
git clone https://github.com/caelestia-dots/shell.git caelestia

cd caelestia
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/
cmake --build build
sudo cmake --install build
```

> [!TIP]
> You can customise the installation location via the `cmake` flags `INSTALL_LIBDIR`, `INSTALL_QMLDIR` and
> `INSTALL_QSCONFDIR` for the libraries (the beat detector), QML plugin and Quickshell config directories
> respectively. If changing the library directory, remember to set the `QUICKSHELL_LIB_DIR` environment
> variable to the custom directory when launching the shell.
>
> e.g. installing to `~/.config/quickshell/caelestia` for easy local changes:
>
> ```sh
> mkdir -p ~/.config/quickshell/caelestia
> cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/ -DINSTALL_QSCONFDIR=~/.config/quickshell/caelestia
> cmake --build build
> sudo cmake --install build
> sudo chown -R $USER ~/.config/quickshell/caelestia
> ```

## Usage

The shell can be started via the `caelestia shell -d` command or `qs -c caelestia`.
If the entire caelestia dots are installed, the shell will be autostarted on login
via an `exec-once` in the hyprland config.

### Shortcuts/IPC

All keybinds are accessible via Hyprland [global shortcuts](https://wiki.hyprland.org/Configuring/Binds/#dbus-global-shortcuts).
If using the entire caelestia dots, the keybinds are already configured for you.
Otherwise, [this file](https://github.com/caelestia-dots/caelestia/blob/main/hypr/hyprland/keybinds.conf#L1-L39)
contains an example on how to use global shortcuts.

All IPC commands can be accessed via `caelestia shell ...`. For example

```sh
caelestia shell mpris getActive trackTitle
```

The list of IPC commands can be shown via `caelestia shell -s`:

```
$ caelestia shell -s
target drawers
  function toggle(drawer: string): void
  function list(): string
target notifs
  function clear(): void
target lock
  function lock(): void
  function unlock(): void
  function isLocked(): bool
target mpris
  function playPause(): void
  function getActive(prop: string): string
  function next(): void
  function stop(): void
  function play(): void
  function list(): string
  function pause(): void
  function previous(): void
target picker
  function openFreeze(): void
  function open(): void
target wallpaper
  function set(path: string): void
  function get(): string
  function list(): string
```

### PFP/Wallpapers

The profile picture for the dashboard is read from the file `~/.face`, so to set
it you can copy your image to there or set it via the dashboard.

The wallpapers for the wallpaper switcher are read from `~/Pictures/Wallpapers`
by default. To change it, change the wallpapers path in `~/.config/caelestia/shell.json`.

To set the wallpaper, you can use the command `caelestia wallpaper`. Use `caelestia wallpaper -h` for more info about
the command.

## Updating

If installed via the AUR package, simply update your system (e.g. using `yay`).

If installed manually, you can update by running `git pull` in `$XDG_CONFIG_HOME/quickshell/caelestia`.

```sh
cd $XDG_CONFIG_HOME/quickshell/caelestia
git pull
```

## Configuring

All configuration options should be put in `~/.config/caelestia/shell.json`. This file is _not_ created by
default, you must create it manually.

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
        "description": "Switch to a random wallpaper",
        "command": ["caelestia", "wallpaper", "-r"],
        "enabled": true,
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
    "maxWallpapers": 9,
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

### My screen is flickering, help pls!

Try disabling VRR in the hyprland config. You can do this by adding the following to `~/.config/caelestia/hypr-user.conf`:

```conf
misc {
    vrr = 0
}
```

### I want to make my own changes to the hyprland config!

You can add your custom hyprland configs to `~/.config/caelestia/hypr-user.conf`.

### I want to make my own changes to other stuff!

See the [manual installation](https://github.com/caelestia-dots/shell?tab=readme-ov-file#manual-installation) section
for the corresponding repo.

### I want to disable XXX feature!

Please read the [configuring](https://github.com/caelestia-dots/shell?tab=readme-ov-file#configuring) section in the readme.
If there is no corresponding option, make feature request.

### How do I make my colour scheme change with my wallpaper?

Set a wallpaper via the launcher or `caelestia wallpaper` and set the scheme to the dynamic scheme via the launcher
or `caelestia scheme set`. e.g.

```sh
caelestia wallpaper -f <path/to/file>
caelestia scheme set -n dynamic
```

### My wallpapers aren't showing up in the launcher!

The launcher pulls wallpapers from `~/Pictures/Wallpapers` by default. You can change this in the config. Additionally,
the launcher only shows an odd number of wallpapers at one time. If you only have 2 wallpapers, consider getting more
(or just putting one).

## Credits

Thanks to the Hyprland discord community (especially the homies in #rice-discussion) for all the help and suggestions
for improving these dots!

A special thanks to [@outfoxxed](https://github.com/outfoxxed) for making Quickshell and the effort put into fixing issues
and implementing various feature requests.

Another special thanks to [@end_4](https://github.com/end-4) for his [config](https://github.com/end-4/dots-hyprland)
which helped me a lot with learning how to use Quickshell.

Finally another thank you to all the configs I took inspiration from (only one for now):

- [Axenide/Ax-Shell](https://github.com/Axenide/Ax-Shell)

## Stonks 📈

<a href="https://www.star-history.com/#caelestia-dots/shell&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=caelestia-dots/shell&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=caelestia-dots/shell&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=caelestia-dots/shell&type=Date" />
 </picture>
</a>
