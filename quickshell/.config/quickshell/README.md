# THIS BRANCH EXISTS ONLY IF I EVER DARE TRY TO COME BACK TO THIS QUICKCOOKED CONFIGURATION

# Quickshell Configuration

A minimal monochrome Wayland shell for Hyprland, forked from [Caelestia](https://github.com/caelestia-dots/shell) and extensively refactored for simplicity.

## Features

- **Minimal Design:** Pure monochrome theme (black/white/grey) with Material Design 3 components
- **Modular Architecture:** Clean separation between components, config, modules, and services
- **Integrated Desktop Elements:** Bar (Left side), Notch + Dashboard (Middle Top), Notifications (Top Right), On-Screen-Display + Session Menu (Middle Right)

## Documentation

All QML files contain header documentation explaining their purpose, features, and relationships. Key files:

- **`shell.qml`** - Entry point that instantiates top-level modules
- **`config/Config.qml`** - Configuration system that loads shell.json
- **`services/`** - Singleton services (Hypr, Brightness, Colours, Audio, etc.)
- **`modules/`** - Feature modules (bar, dashboard, controlcenter, drawers, notch, notifcations, osd, session, sidebar, )
- **`components/`** - Reusable UI building blocks

---

## Directory Structure & XDG Paths

This configuration uses the XDG Base Directory specification:

### **Config Directory (`~/.config/quickshell/`)**

**Purpose:** QML source code and main configuration file.

**Contains:**

- `shell.json` - Main configuration (bar layout, enabled features, settings)
- `*.qml` files - QML source code (symlinked from dotfiles repo via stow)

---

### **State Directory (`~/.local/state/quickshell/`)**

**Purpose:** Runtime state that persists between sessions.

**Contains:**

- `apps.sqlite` - Application launch history for launcher sorting
- `notifs.json` - Notification state/history

---

### **Cache Directory (`~/.cache/quickshell/`)**

**Purpose:** Temporary cached data (safe to delete).

**Contains:**

- `imagecache/` - Processed images for faster loading

---

## Installation

### Prerequisites

**Runtime Dependencies:**

- [`quickshell-git`](https://quickshell.outfoxxed.me)
- [`hyprland`](https://hyprland.org) - Wayland compositor
- [`hyprpaper`](https://github.com/hyprwm/hyprpaper) - Wallpaper daemon
- [`brightnessctl`](https://github.com/Hummer12007/brightnessctl) - Brightness control
- [`networkmanager`](https://networkmanager.dev) - Network management
- [`pipewire`](https://pipewire.org) - Audio system
- `qt6-declarative`, `qt6-base` - Qt runtime
- [`material-symbols`](https://fonts.google.com/icons) - Icon font
- [`ttf-caskaydia-cove-nerd`](https://www.nerdfonts.com/font-downloads) - Monospace font

**Build Dependencies:**

- [`cmake`](https://cmake.org), [`ninja`](https://github.com/ninja-build/ninja) - Build system
- `gcc` or `clang` - C++ compiler
- [`libqalculate`](https://github.com/Qalculate/libqalculate) - Calculator library

**Optional:**

- [`ddcutil`](https://github.com/rockowitz/ddcutil) - External monitor brightness
- [`lm-sensors`](https://github.com/lm-sensors/lm-sensors) - Temperature monitoring

---

### Installation Steps

#### 1. Build C++ QML Plugins

The configuration requires custom QML plugins for audio visualization, and Hyprland integration:

```sh
cd ~/dotfiles/quickshell/.config/quickshell

# Build and install plugins
rm -rf build
cmake -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/ \
  -DVERSION=1.0.0 \
  -DGIT_REVISION=refactored \
  -DENABLE_MODULES="extras;plugin;shell"
cmake --build build
```

**Plugins installed:**

- **QShell** - Core utilities (calculator, app database, toast notifications)
- **QShell.Audio** - audio collector, Cava visualizer
- **QShell.Hyprland** - Hyprland keyboard state, image caching, device management
- **QShell.Models** - Filesystem models for file dialogs

These are installed to `/usr/lib/qt6/qml/QShell/` and imported in QML as `import QShell`, etc.

---

#### 2. Stow the Configuration

Use GNU Stow to symlink the configuration:

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
```

> [!NOTE]
> The `build/` directory is already excluded from stow via `.stow-local-ignore`.

---

#### 3. Add to Hyprland Config

Add to `~/.config/hypr/hyprland.conf`:

```conf
# Start quickshell
exec-once = qs -c ~/.config/quickshell
```

---

### Update Configuration

```sh
cd ~/dotfiles
git pull
stow -R quickshell
```

---

## Environment Variables

Customize paths using environment variables:

- `QUICKSHELL_LIB_DIR` - Override library directory (default: `/usr/lib/quickshell`)
- `QUICKSHELL_XKB_RULES_PATH` - Override keyboard layout rules

---

## Credits

This configuration is a refactored version of [Caelestia](https://github.com/caelestia-dots/shell).

Thanks to:

- [@outfoxxed](https://github.com/outfoxxed) for creating Quickshell
- [Caelestia](https://github.com/caelestia-dots/shell) for the original configuration
