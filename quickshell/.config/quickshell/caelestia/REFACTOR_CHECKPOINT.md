# Caelestia Quickshell - Minimal Monochrome Refactor

**Date:** 2025-10-03
**Last Updated:** 2025-10-03 (Dashboard Re-enabled)
**Status:** Working ✅
**Theme:** Pure Monochrome (Black/White/Grey)
**Dependencies Removed:** caelestia-cli, swww

---

## 📝 Recent Updates

### **Dashboard Re-enabled (2025-10-03 22:55)**
- ✅ Dashboard widget menu restored
- ✅ Media player with aubio beat detection
- ✅ Audio visualizer with Cava (45 bars)
- ✅ System performance stats (CPU/RAM/GPU)
- ✅ Profile picture section
- Access: Hover at top of screen or use dashboard keybind

### **Media Widget Modernized (2025-10-03 23:00)**
- ✅ Removed bongocat.gif animation
- ✅ Album artwork now rectangular with rounded corners
- ✅ Horizontal bar visualizer overlaying bottom of artwork
- ✅ Modern, clean layout similar to Spotify/Apple Music
- ✅ All playback controls remain unchanged
- ✅ Visualizer bars sync with audio in real-time

---

## 🎯 Overview of Changes

This refactor transforms Caelestia from a full-featured desktop shell into a **minimal, monochrome UI overlay system** that:

- ✅ Provides only GUI elements (bar, launcher, menus, OSD)
- ✅ Uses pure black/white/grey color scheme
- ✅ Lets hyprpaper manage wallpapers independently
- ✅ Removes CLI dependencies (caelestia-cli)
- ✅ Disables heavy features (dashboard, sidebar, lock screen, background management)

---

## 📁 Files Modified

### **1. Core Shell Configuration**

#### `shell.qml` (Main Entry Point)
**Location:** `/home/hvenry/dotfiles/quickshell/.config/quickshell/caelestia/shell.qml`

**Before:**
```qml
import "modules"
import "modules/drawers"
import "modules/background"
import "modules/areapicker"
import "modules/lock"
import Quickshell

ShellRoot {
    Background {}
    Drawers {}
    AreaPicker {}
    Lock {
        id: lock
    }

    Shortcuts {}
    BatteryMonitor {}
    IdleMonitors {
        lock: lock
    }
}
```

**After:**
```qml
import "modules"
import "modules/drawers"
import Quickshell

ShellRoot {
    // Background disabled - using hyprpaper externally
    Drawers {}

    Shortcuts {}
}
```

**Changes:**
- ❌ Removed `Background {}` module
- ❌ Removed `AreaPicker {}` (screenshot area picker)
- ❌ Removed `Lock {}` (lock screen)
- ❌ Removed `BatteryMonitor {}`
- ❌ Removed `IdleMonitors {}`
- ✅ Kept `Drawers {}` (bar, launcher, panels)
- ✅ Kept `Shortcuts {}` (IPC/keybinds)

---

### **2. Service Files (Removing CLI Dependencies)**

#### `services/Wallpapers.qml`
**Location:** `/home/hvenry/dotfiles/quickshell/.config/quickshell/caelestia/services/Wallpapers.qml`

**Changes:**
```qml
// OLD: Used caelestia CLI
function setWallpaper(path: string): void {
    actualCurrent = path;
    Quickshell.execDetached(["caelestia", "wallpaper", "-f", path, ...smartArg]);
}

// NEW: Uses hyprpaper directly
function setWallpaper(path: string): void {
    actualCurrent = path;
    // Use hyprpaper to set wallpaper
    // First preload the image
    Quickshell.execDetached(["hyprctl", "hyprpaper", "preload", path]);
    // Then set it on all monitors (,* sets on all)
    Quickshell.execDetached(["hyprctl", "hyprpaper", "wallpaper", `,${path}`]);
    // Write to state file
    Quickshell.execDetached(["sh", "-c", `echo "${path}" > ${currentNamePath}`]);
}
```

**Disabled Features:**
- Preview wallpaper with color extraction (requires CLI)
- Dynamic color scheme generation from wallpaper

---

#### `services/Colours.qml`
**Location:** `/home/hvenry/dotfiles/quickshell/.config/quickshell/caelestia/services/Colours.qml`

**Changes:**
```qml
// OLD: Used caelestia CLI to change light/dark mode
function setMode(mode: string): void {
    Quickshell.execDetached(["caelestia", "scheme", "set", "--notify", "-m", mode]);
}

// NEW: Disabled, manual JSON editing required
function setMode(mode: string): void {
    // Disabled: requires caelestia CLI
    // To change mode manually, edit ~/.local/state/caelestia/scheme.json
    console.log("setMode disabled - edit scheme.json manually to change light/dark mode");
}
```

---

#### `modules/launcher/services/Schemes.qml`
**Location:** `/home/hvenry/dotfiles/quickshell/.config/quickshell/caelestia/modules/launcher/services/Schemes.qml`

**Changes:**
- Commented out `Process` that runs `caelestia scheme list`
- Commented out `Process` that runs `caelestia scheme get`
- Added `Component.onCompleted: { schemes.model = []; }` to set empty model
- Disabled scheme switching in launcher

---

#### `modules/launcher/services/M3Variants.qml`
**Location:** `/home/hvenry/dotfiles/quickshell/.config/quickshell/caelestia/modules/launcher/services/M3Variants.qml`

**Changes:**
```qml
// OLD: Used caelestia CLI to change variant
function onClicked(list: AppList): void {
    list.visibilities.launcher = false;
    Quickshell.execDetached(["caelestia", "scheme", "set", "-v", variant]);
}

// NEW: Disabled
function onClicked(list: AppList): void {
    list.visibilities.launcher = false;
    // Disabled: requires caelestia CLI
    // To change variant, edit ~/.local/state/caelestia/scheme.json manually
    console.log("Variant switching disabled - edit scheme.json manually");
}
```

---

### **3. User Configuration Files**

#### `~/.config/caelestia/shell.json` (Created)
**Location:** `/home/hvenry/.config/caelestia/shell.json`

**Full Content:**
```json
{
  "services": {
    "smartScheme": false,
    "audioIncrement": 0.1,
    "defaultPlayer": "Spotify",
    "gpuType": "",
    "playerAliases": [],
    "weatherLocation": "",
    "useFahrenheit": false,
    "useTwelveHourClock": false,
    "visualiserBars": 45
  },
  "appearance": {
    "transparency": {
      "enabled": false
    }
  },
  "general": {
    "apps": {
      "terminal": ["kitty"],
      "audio": ["pavucontrol"],
      "playback": ["mpv"],
      "explorer": ["thunar"]
    }
  },
  "bar": {
    "entries": [
      {"id": "logo", "enabled": true},
      {"id": "workspaces", "enabled": true},
      {"id": "spacer", "enabled": true},
      {"id": "activeWindow", "enabled": true},
      {"id": "spacer", "enabled": true},
      {"id": "clock", "enabled": true},
      {"id": "statusIcons", "enabled": true},
      {"id": "power", "enabled": true}
    ],
    "status": {
      "showAudio": true,
      "showBattery": true,
      "showNetwork": true,
      "showBluetooth": false,
      "showKbLayout": false,
      "showMicrophone": false,
      "showLockStatus": false
    },
    "persistent": true,
    "tray": {
      "background": false,
      "compact": true
    }
  },
  "background": {
    "enabled": false,
    "desktopClock": {
      "enabled": false
    },
    "visualiser": {
      "enabled": false
    }
  },
  "launcher": {
    "actions": [
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
    "useFuzzy": {
      "apps": false,
      "actions": false,
      "schemes": false,
      "variants": false,
      "wallpapers": false
    },
    "maxShown": 7,
    "vimKeybinds": false,
    "enableDangerousActions": true,
    "maxWallpapers": 0
  },
  "osd": {
    "enabled": true,
    "enableBrightness": true,
    "enableMicrophone": false,
    "hideDelay": 2000
  },
  "session": {
    "enabled": true,
    "vimKeybinds": false,
    "commands": {
      "logout": ["loginctl", "terminate-user", ""],
      "shutdown": ["systemctl", "poweroff"],
      "hibernate": ["systemctl", "hibernate"],
      "reboot": ["systemctl", "reboot"]
    }
  },
  "dashboard": {
    "enabled": true,
    "dragThreshold": 50,
    "mediaUpdateInterval": 500,
    "showOnHover": true
  },
  "sidebar": {
    "enabled": false
  },
  "utilities": {
    "enabled": false
  },
  "notifs": {
    "expire": false,
    "defaultExpireTimeout": 5000
  },
  "paths": {
    "wallpaperDir": ""
  }
}
```

**Key Settings:**
- `background.enabled: false` - No background management
- `dashboard.enabled: false` - No dashboard
- `sidebar.enabled: false` - No sidebar
- `utilities.enabled: false` - No utilities/toasts
- `maxWallpapers: 0` - No wallpaper picker
- `smartScheme: false` - Static color scheme only

---

#### `~/.local/state/caelestia/scheme.json` (Replaced)
**Location:** `/home/hvenry/.local/state/caelestia/scheme.json`

**Full Content:**
```json
{
  "name": "monochrome",
  "flavour": "dark",
  "mode": "dark",
  "variant": "monochrome",
  "colours": {
    "primary_paletteKeyColor": "ffffff",
    "secondary_paletteKeyColor": "b0b0b0",
    "tertiary_paletteKeyColor": "808080",
    "neutral_paletteKeyColor": "5a5a5a",
    "neutral_variant_paletteKeyColor": "5a5a5a",
    "background": "0a0a0a",
    "onBackground": "e8e8e8",
    "surface": "0a0a0a",
    "surfaceDim": "0a0a0a",
    "surfaceBright": "2e2e2e",
    "surfaceContainerLowest": "050505",
    "surfaceContainerLow": "121212",
    "surfaceContainer": "181818",
    "surfaceContainerHigh": "232323",
    "surfaceContainerHighest": "2e2e2e",
    "onSurface": "e8e8e8",
    "surfaceVariant": "404040",
    "onSurfaceVariant": "c0c0c0",
    "inverseSurface": "e8e8e8",
    "inverseOnSurface": "2a2a2a",
    "outline": "8a8a8a",
    "outlineVariant": "404040",
    "shadow": "000000",
    "scrim": "000000",
    "surfaceTint": "ffffff",
    "primary": "ffffff",
    "onPrimary": "1a1a1a",
    "primaryContainer": "b0b0b0",
    "onPrimaryContainer": "000000",
    "inversePrimary": "5a5a5a",
    "secondary": "c0c0c0",
    "onSecondary": "2a2a2a",
    "secondaryContainer": "404040",
    "onSecondaryContainer": "b0b0b0",
    "tertiary": "b0b0b0",
    "onTertiary": "1a1a1a",
    "tertiaryContainer": "808080",
    "onTertiaryContainer": "000000",
    "error": "ff6b6b",
    "onError": "690005",
    "errorContainer": "93000a",
    "onErrorContainer": "ffdad6",
    "primaryFixed": "e8e8e8",
    "primaryFixedDim": "c0c0c0",
    "onPrimaryFixed": "0a0a0a",
    "onPrimaryFixedVariant": "404040",
    "secondaryFixed": "d0d0d0",
    "secondaryFixedDim": "b0b0b0",
    "onSecondaryFixed": "0a0a0a",
    "onSecondaryFixedVariant": "404040",
    "tertiaryFixed": "d0d0d0",
    "tertiaryFixedDim": "b0b0b0",
    "onTertiaryFixed": "0a0a0a",
    "onTertiaryFixedVariant": "404040",
    "term0": "0a0a0a",
    "term1": "808080",
    "term2": "a0a0a0",
    "term3": "b0b0b0",
    "term4": "c0c0c0",
    "term5": "d0d0d0",
    "term6": "e0e0e0",
    "term7": "e8e8e8",
    "term8": "5a5a5a",
    "term9": "909090",
    "term10": "b0b0b0",
    "term11": "c0c0c0",
    "term12": "d0d0d0",
    "term13": "e0e0e0",
    "term14": "f0f0f0",
    "term15": "ffffff",
    "rosewater": "e8e8e8",
    "flamingo": "d8d8d8",
    "pink": "d0d0d0",
    "mauve": "c0c0c0",
    "red": "b0b0b0",
    "maroon": "a8a8a8",
    "peach": "a0a0a0",
    "yellow": "989898",
    "green": "909090",
    "teal": "888888",
    "sky": "808080",
    "sapphire": "787878",
    "blue": "707070",
    "lavender": "686868",
    "klink": "909090",
    "klinkSelection": "909090",
    "kvisited": "808080",
    "kvisitedSelection": "808080",
    "knegative": "a0a0a0",
    "knegativeSelection": "a0a0a0",
    "kneutral": "b0b0b0",
    "kneutralSelection": "b0b0b0",
    "kpositive": "c0c0c0",
    "kpositiveSelection": "c0c0c0",
    "text": "e8e8e8",
    "subtext1": "c0c0c0",
    "subtext0": "8a8a8a",
    "overlay2": "707070",
    "overlay1": "606060",
    "overlay0": "505050",
    "surface2": "404040",
    "surface1": "303030",
    "surface0": "202020",
    "base": "0a0a0a",
    "mantle": "0a0a0a",
    "crust": "050505",
    "success": "a0a0a0",
    "onSuccess": "1a1a1a",
    "successContainer": "505050",
    "onSuccessContainer": "d0d0d0"
  }
}
```

**Color Palette:**
- Background: `#0a0a0a` (near black)
- Primary: `#ffffff` (white)
- Surface: Shades of grey (`#121212` to `#2e2e2e`)
- Text: `#e8e8e8` (light grey)
- All colors are pure greyscale

---

## 🗑️ Features Removed/Disabled

### **Modules Completely Removed:**
1. ❌ **Background** - Desktop wallpaper/clock/visualizer management
2. ❌ **Lock Screen** - PAM authentication lock screen
3. ❌ **Area Picker** - Screenshot area selection tool
4. ❌ **Battery Monitor** - Low battery notifications
5. ❌ **Idle Monitors** - Auto-lock on idle

### **Modules Disabled via Config:**
1. ✅ **Dashboard** - **RE-ENABLED** - Media player with beat detection, system stats, profile
2. ❌ **Sidebar** - Notification center
3. ❌ **Utilities** - Toast notifications, screen recorder controls
4. ❌ **Control Center** - Settings panel (can still be launched via keybind if needed)

### **Launcher Actions Removed:**
1. ❌ Calculator (`["autocomplete", "calc"]`)
2. ❌ Scheme switcher (`["autocomplete", "scheme"]`)
3. ❌ Wallpaper picker (`["autocomplete", "wallpaper"]`)
4. ❌ Variant switcher (`["autocomplete", "variant"]`)
5. ❌ Random wallpaper (`["caelestia", "wallpaper", "-r"]`)
6. ❌ Light/Dark mode toggle (`["setMode", "light"]`)
7. ❌ Transparency changer

### **Services Disabled:**
1. ❌ Dynamic color extraction from wallpapers
2. ❌ Wallpaper preview with color changes
3. ❌ Scheme listing/switching
4. ❌ Variant switching
5. ❌ Audio visualizer

---

## ✅ Features Still Active

### **Working Modules:**
1. ✅ **Bar** - Workspace switcher, clock, status icons, system tray
2. ✅ **Launcher** - Application launcher with search
3. ✅ **Dashboard** - Media player with beat detection, system stats, profile picture
4. ✅ **Session Menu** - Power menu (shutdown, reboot, logout, sleep, lock)
5. ✅ **OSD** - Volume and brightness on-screen display
6. ✅ **Notifications** - Popup notifications
7. ✅ **Shortcuts** - IPC handlers for keybinds

### **Bar Components:**
- Logo/launcher button
- Workspaces (Hyprland workspace switcher)
- Active window title
- Clock
- Status icons (audio, battery, network)
- System tray
- Power button

### **Launcher Features:**
- App search and launch
- Power actions (shutdown, reboot, logout, lock, sleep)

---

## 📦 Dependencies

### **Required:**
- `quickshell-git` - Main shell
- `hyprpaper` - Wallpaper management
- `hyprland` - Window manager
- `qt6-declarative` - Qt QML runtime
- `qt6-base` - Qt base libraries
- `gcc-libs` - C++ runtime
- `glibc` - C standard library
- `brightnessctl` - Brightness control
- `networkmanager` - Network management
- `pipewire` - Audio system
- `aubio` - Beat detection for media player **[RE-ADDED]**
- `libcava` - Audio visualizer **[RE-ADDED]**
- `material-symbols` font - Icons
- `caskaydia-cove-nerd` font - Monospace font

### **Optional (for specific features):**
- `ddcutil` - External monitor brightness control
- `lm-sensors` - Temperature monitoring
- `pavucontrol` - Audio settings GUI

### **No Longer Needed:**
- ❌ `caelestia-cli` - Removed completely
- ❌ `swww` - Using hyprpaper instead
- ❌ `swappy` - Utilities disabled
- ❌ `libqalculate` - Calculator disabled
- ❌ PAM dependencies - Lock screen disabled
- ❌ `app2unit` - Not used in minimal config

---

## 🚀 Usage

### **Starting the Shell:**
```bash
qs -c caelestia
```

Or add to `~/.config/hypr/hyprland.conf`:
```conf
exec-once = hyprpaper
exec-once = qs -c caelestia
```

### **Managing Wallpapers (Hyprpaper):**

Create `~/.config/hypr/hyprpaper.conf`:
```conf
preload = ~/Pictures/Wallpapers/wallpaper.jpg
wallpaper = ,~/Pictures/Wallpapers/wallpaper.jpg
splash = false
ipc = on
```

Change wallpaper manually:
```bash
hyprctl hyprpaper preload ~/Pictures/new-wallpaper.jpg
hyprctl hyprpaper wallpaper ",~/Pictures/new-wallpaper.jpg"
```

### **Changing Theme Colors:**
Edit `~/.local/state/caelestia/scheme.json` and modify the `colours` object. The shell will reload automatically.

### **Changing Light/Dark Mode:**
Edit `~/.local/state/caelestia/scheme.json`:
```json
{
  "mode": "light"   // or "dark"
}
```

---

## 🔄 How to Revert

### **To Restore Original Caelestia:**

1. **Restore `shell.qml`:**
```bash
cd /home/hvenry/dotfiles/quickshell/.config/quickshell/caelestia
git checkout shell.qml
```

2. **Restore service files:**
```bash
git checkout services/Wallpapers.qml
git checkout services/Colours.qml
git checkout modules/launcher/services/Schemes.qml
git checkout modules/launcher/services/M3Variants.qml
```

3. **Delete custom config:**
```bash
rm ~/.config/caelestia/shell.json
rm ~/.local/state/caelestia/scheme.json
```

4. **Reinstall caelestia-cli:**
```bash
yay -S caelestia-cli
```

5. **Generate new scheme:**
```bash
caelestia scheme set -n catppuccin
caelestia wallpaper -f ~/Pictures/Wallpapers/your-wallpaper.jpg
```

---

## 📝 Summary of File Changes

| File | Location | Action | Purpose |
|------|----------|--------|---------|
| `shell.qml` | `~/.config/quickshell/caelestia/` | Modified | Removed Background, Lock, AreaPicker modules |
| `services/Wallpapers.qml` | `~/.config/quickshell/caelestia/services/` | Modified | Replaced CLI with hyprpaper commands |
| `services/Colours.qml` | `~/.config/quickshell/caelestia/services/` | Modified | Disabled setMode() function |
| `modules/launcher/services/Schemes.qml` | `~/.config/quickshell/caelestia/modules/launcher/services/` | Modified | Disabled scheme listing |
| `modules/launcher/services/M3Variants.qml` | `~/.config/quickshell/caelestia/modules/launcher/services/` | Modified | Disabled variant switching |
| `modules/dashboard/Media.qml` | `~/.config/quickshell/caelestia/modules/dashboard/` | Modified | Horizontal visualizer, removed bongocat |
| `shell.json` | `~/.config/caelestia/` | Created | Main config with features disabled |
| `scheme.json` | `~/.local/state/caelestia/` | Replaced | Monochrome color scheme |

---

## 🎨 Color Reference

**Monochrome Palette:**
```
Background:     #0a0a0a (near black)
Surface:        #181818 (dark grey)
Surface Bright: #2e2e2e (medium grey)
Primary:        #ffffff (white)
Text:           #e8e8e8 (light grey)
Outline:        #8a8a8a (medium grey)
```

**All colors are pure greyscale - no hue, no saturation, only lightness values.**

---

## 🔧 Customization Tips

### **To Change Base Colors:**
Edit `~/.local/state/caelestia/scheme.json`:
- `background` - Main background color
- `surface` - Panel backgrounds
- `primary` - Accent color (buttons, highlights)
- `onPrimary` - Text on primary color
- `text` - Main text color

### **To Add Bar Entries:**
Edit `~/.config/caelestia/shell.json` → `bar.entries[]`:
```json
{"id": "tray", "enabled": true}
```

Available entries: `logo`, `workspaces`, `activeWindow`, `tray`, `clock`, `statusIcons`, `power`, `spacer`

### **To Change Terminal/Apps:**
Edit `~/.config/caelestia/shell.json` → `general.apps`:
```json
{
  "terminal": ["alacritty"],
  "explorer": ["nautilus"]
}
```

---

## 🐛 Known Issues

1. **Wallpaper preview in launcher doesn't work** - Dynamic color extraction requires caelestia-cli
2. **Scheme/variant switching disabled** - Must edit JSON files manually
3. **No lock screen** - Use system lock (`hyprlock` or `swaylock`) instead

---

## ✨ What's Next?

Potential further customizations:
- Re-enable specific features (dashboard, sidebar, etc.)
- Create custom launcher actions
- Adjust bar layout and components
- Fine-tune color values
- Add custom keybinds

---

**Last Updated:** 2025-10-03
**Quickshell Version:** git (latest)
**Configuration Type:** Minimal Monochrome
