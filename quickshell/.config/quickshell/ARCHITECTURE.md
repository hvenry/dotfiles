# Quickshell Configuration Architecture

This document explains the architectural organization of this Quickshell configuration, how the different directories
interact, and provides visual representations of the GUI components.

## Directory Structure Overview

```
quickshell/
├── shell.qml              # Entry point - instantiates top-level modules
├── shell.json             # User-editable configuration (feature toggles, settings)
├── scheme.json            # Color scheme definition (Material Design 3 tokens)
├── components/            # Reusable UI building blocks
├── config/                # Configuration system (reads shell.json)
├── modules/               # High-level feature modules (bar, launcher, etc.)
├── services/              # Singleton services (global state and functionality)
├── utils/                 # Utility singletons (paths, icons, etc.)
├── plugin/                # C++ QML plugins (compiled separately)
└── extras/                # Additional C++ QML modules
```

## Directory Purposes

### `components/` - Reusable UI Components

**Purpose:** Low-level, reusable GUI building blocks that implement the visual design system.

**Key characteristics:**

- Generic, configurable components used throughout the application
- Implement Material Design 3 design language
- Read from `Colours` (scheme.json) and `Appearance` (shell.json) for theming
- Do NOT contain application logic - only presentation

**Categories:**

1. **Base Components** (root level)
   - `StyledRect.qml` - Base rectangle with color animation
   - `StyledText.qml` - Themed text component
   - `StyledClippingRect.qml` - Rectangle with clipping for rounded corners
   - `MaterialIcon.qml` - Material Design icon font renderer
   - `StateLayer.qml` - Ripple/hover effect layer
   - `Anim.qml`, `CAnim.qml` - Animation helpers

2. **Containers** (`components/containers/`)
   - `StyledWindow.qml` - Base window with theming
   - `StyledFlickable.qml` - Scrollable area
   - `StyledListView.qml` - List container

3. **Controls** (`components/controls/`)
   - Buttons: `IconButton.qml`, `TextButton.qml`, `IconTextButton.qml`, `SplitButton.qml`
   - Inputs: `StyledTextField.qml`, `CustomSpinBox.qml`, `FilledSlider.qml`, `StyledSlider.qml`
   - Toggles: `StyledSwitch.qml`, `StyledRadioButton.qml`
   - Navigation: `Menu.qml`, `MenuItem.qml`
   - Visual feedback: `CircularIndicator.qml`, `CircularProgress.qml`
   - Utility: `CustomMouseArea.qml`, `StyledScrollBar.qml`

4. **Effects** (`components/effects/`)
   - `Elevation.qml` - Shadow effects for depth
   - `ColouredIcon.qml`, `Colouriser.qml` - Icon colorization
   - `InnerBorder.qml` - Border rendering
   - `OpacityMask.qml` - Masking effects

5. **Images** (`components/images/`)
   - `CachingImage.qml` - Image with caching support
   - `CachingIconImage.qml` - Cached icon rendering

6. **Misc** (`components/misc/`)
   - `CustomShortcut.qml` - Keyboard shortcut handler
   - `Ref.qml` - Reference utility

7. **File Dialog** (`components/filedialog/`)
   - Complete file picker implementation (unused in minimal config)

8. **Widgets** (`components/widgets/`)
   - `ExtraIndicator.qml` - Generic status indicator

**Relationship to other directories:**

- Used BY: `modules/` (compose components into features)
- Reads FROM: `services/Colours` (colors), `config/Appearance` (spacing, fonts, animations)
- Does NOT read: `shell.json` directly (reads through `Appearance` singleton)

---

### `config/` - Configuration System

**Purpose:** Manages user-editable settings from `shell.json` and provides typed access throughout the application.

**Key characteristics:**

- Bridges `shell.json` (JSON data) and QML (typed objects)
- Watches `shell.json` for changes and hot-reloads
- Provides structured configuration objects for each module
- Does NOT contain application logic

**Key files:**

1. **`Config.qml`** - Main configuration singleton
   - Loads `shell.json` using `FileView` and `JsonAdapter`
   - Exposes configuration sections as properties: `Config.bar`, `Config.launcher`, etc.
   - Handles hot-reload on file changes
   - Shows toast notifications on config load/error

2. **`Appearance.qml`** - Shortcut singleton
   - Convenience wrapper around `Config.appearance`
   - Allows `Appearance.spacing.large` instead of `Config.appearance.spacing.large`

3. **Config objects** (one per module):
   - `AppearanceConfig.qml` - Visual settings (fonts, spacing, rounding, animations)
   - `BarConfig.qml` - Bar layout and persistent mode
   - `LauncherConfig.qml` - Launcher actions and fuzzy search settings
   - `DashboardConfig.qml` - Dashboard drag threshold and hover behavior
   - `SessionConfig.qml` - Session menu vim keybinds and commands
   - `SidebarConfig.qml` - Sidebar enabled state
   - `NotifsConfig.qml` - Notification expiration settings
   - `OsdConfig.qml` - OSD (On-Screen Display) settings
   - `ServiceConfig.qml` - Service-level settings (audio increment, player aliases)
   - `GeneralConfig.qml` - Default applications (terminal, file manager, etc.)
   - Plus: `BackgroundConfig`, `BorderConfig`, `ControlCenterConfig`, `LockConfig`, `UtilitiesConfig`, `WInfoConfig`

**Relationship to other directories:**

- Reads FROM: `shell.json` (user settings file)
- Used BY: All `modules/`, most `components/`, some `services/`
- Works with: `utils/Paths.qml` to resolve file paths

---

### `modules/` - High-Level Feature Modules

**Purpose:** Application features that compose components into complete UI modules.

**Key characteristics:**

- Implement specific user-facing features (bar, launcher, notifications, etc.)
- Compose `components/` into layouts
- Read from `config/` for settings
- Call `services/` for state and actions
- Each module typically has `Wrapper.qml`, `Content.qml`, `Background.qml`

**Active modules:**

1. **`modules/drawers/`** - Main shell window system
   - `Drawers.qml` - Creates per-screen windows
   - `Panels.qml` - Container for all panels (bar, launcher, dashboard, etc.)
   - `Interactions.qml` - Mouse/keyboard interaction handling
   - `Backgrounds.qml` - Panel background rendering
   - `Border.qml` - Screen border decoration
   - `Exclusions.qml` - Manages reserved screen areas

2. **`modules/bar/`** - Left Screen bar (MAIN BAR)
   - `Bar.qml`, `BarWrapper.qml` - Main bar implementation
   - `components/` - Bar widgets:
     - `OsIcon.qml` - Logo button
     - `Workspaces.qml` - Hyprland workspace indicators
     - `ActiveWindow.qml` - Current window title
     - `Clock.qml` - Date/time display
     - `StatusIcons.qml` - System status icons (audio, network, battery, etc.)
     - `Power.qml` - Power button
     - `Tray.qml`, `TrayItem.qml` - System tray
   - `popouts/` - Popout menus from bar icons:
     - `Audio.qml` - Volume control
     - `Network.qml` - WiFi/Ethernet management
     - `Bluetooth.qml` - Bluetooth device management
     - `Battery.qml` - Battery status
     - `ActiveWindow.qml` - Window management
     - `TrayMenu.qml` - Tray item menus

3. **`modules/launcher/`** - Application launcher
   - `Content.qml` - Main launcher UI
   - `AppList.qml` - Application search/list
   - `ContentList.qml` - Generic result list
   - `WallpaperList.qml` - Wallpaper picker
   - `items/` - Result item types:
     - `AppItem.qml` - Application entry
     - `ActionItem.qml` - System action (shutdown, reboot, etc.)
     - `CalcItem.qml` - Calculator result
     - `SchemeItem.qml` - Color scheme picker
     - `VariantItem.qml` - Scheme variant picker
     - `WallpaperItem.qml` - Wallpaper thumbnail
   - `services/` - Launcher-specific services:
     - `Apps.qml` - Application database and search
     - `Actions.qml` - System actions
     - `Schemes.qml` - Color scheme management
     - `M3Variants.qml` - Material 3 variant options

4. **`modules/dashboard/`** - Info dashboard (top pulldown)
   - `Content.qml` - Main dashboard container
   - `Tabs.qml` - Tab navigation (Dash, Media, Performance)
   - `dash/` - Dashboard widgets:
     - `DateTime.qml` - Large date/time display
     - `Calendar.qml` - Month calendar
     - `User.qml` - User profile info
     - `Media.qml` - Media player controls
     - `Resources.qml` - System resource usage
     - `Weather.qml` - Weather information

5. **`modules/session/`** - Session menu (logout, shutdown, etc.)
   - `Content.qml` - Session action buttons
   - `Background.qml` - Modal background overlay

6. **`modules/sidebar/`** - Notification center (right sidebar)
   - `Content.qml` - Notification list
   - `Notif.qml` - Individual notification
   - `NotifGroup.qml` - Grouped notifications
   - `NotifDock.qml` - Notification dock item
   - `Props.qml` - Notification properties manager

7. **`modules/notifications/`** - Notification popups
   - `Notification.qml` - Popup notification display

8. **`modules/osd/`** - On-Screen Display (volume/brightness indicators)
   - `Content.qml` - OSD display with progress bar

9. **`modules/utilities/`** - Utility panel (disabled in minimal config)
   - Recording controls, idle inhibit, etc.

**Disabled modules (exist but not enabled in shell.qml):**

- `modules/background/` - Desktop background with clock/visualizer
- `modules/lock/` - Lock screen
- `modules/areapicker/` - Screenshot area picker
- `modules/controlcenter/` - Alternative to sidebar (control center UI)
- `modules/windowinfo/` - Window information display

**Relationship to other directories:**

- Uses: `components/` (UI building blocks)
- Reads: `config/` (settings)
- Calls: `services/` (state and actions)
- Imported BY: `shell.qml` (entry point)

---

### `services/` - Singleton Services

**Purpose:** Global state management and system integration.

**Key characteristics:**

- All files are `pragma Singleton` - one instance shared across application
- Provide reactive properties that modules bind to
- Interface with system APIs (Hyprland, PipeWire, NetworkManager, etc.)
- Do NOT contain UI - only state and logic

**Service files:**

1. **`Hypr.qml`** - Hyprland integration
   - Properties: `toplevels`, `workspaces`, `monitors`, `activeToplevel`, `focusedWorkspace`, `keyboard`
   - Functions: `dispatch()`, `monitorFor()`, `reloadDynamicConfs()`
   - Uses: `QShell.Hyprland` C++ plugin for device management
   - Manages keyboard state (Caps Lock, Num Lock, layout)

2. **`Brightness.qml`** - Display brightness control
   - Multi-backend: `ddcutil` (external monitors), `brightnessctl` (laptops), `asdbctl` (Apple displays)
   - Functions: `getMonitor()`, `increaseBrightness()`, `decreaseBrightness()`
   - Detects monitors via DDC/CI, maps to I2C bus numbers
   - Queues brightness changes to avoid DDC rate limiting

3. **`Audio.qml`** - Audio management via PipeWire
   - Properties: `defaultSpeaker`, `defaultMicrophone`, `speakers`, `microphones`
   - Functions: `getPreferredSink()`, `getPreferredSource()`, volume controls
   - Uses: `QShell.Audio` C++ plugin

4. **`Colours.qml`** - Color scheme management
   - Reads: `scheme.json` (Material Design 3 color tokens)
   - Provides: `Colours.palette.m3primary`, `Colours.palette.m3surface`, etc.
   - Manages transparency settings
   - Currently uses pure monochrome scheme

5. **`Wallpapers.qml`** - Wallpaper management
   - Interfaces with `hyprpaper` daemon
   - Functions: `setWallpaper()`, `preload()`, `unload()`
   - Scans wallpaper directory for images

6. **`Players.qml`** - Media player control (MPRIS2)
   - Properties: `active` (currently playing player), `players` (all players)
   - Functions: `play()`, `pause()`, `next()`, `previous()`

7. **`Network.qml`** - Network management (NetworkManager)
   - Properties: WiFi/Ethernet state, available networks
   - Functions: `connect()`, `disconnect()`, `scan()`

8. **`Notifs.qml`** - Notification system
   - Manages notification queue, persistence, dismissal
   - Reads: `~/.local/state/quickshell/notifs.json`

9. **`Time.qml`** - Time/date utilities
   - Provides formatted time strings, date calculations

10. **`SystemUsage.qml`** - System resource monitoring
    - CPU, memory, disk usage tracking

11. **`Visibilities.qml`** - Panel visibility state
    - Tracks which panels are currently visible
    - Manages per-screen visibility state

12. **`GameMode.qml`**, `IdleInhibitor.qml`, `Recorder.qml`, `Weather.qml` - Additional services

**Relationship to other directories:**

- Used BY: `modules/` (read state, call actions)
- Reads: `scheme.json` (Colours), `shell.json` via `Config` (some services)
- Uses: C++ plugins from `plugin/` and `extras/`

---

### `utils/` - Utility Singletons

**Purpose:** Helper utilities that don't fit into services (more like static helper functions).

**Key characteristics:**

- Singletons, but no reactive state (mostly pure functions)
- Provide conveniences for common operations

**Utility files:**

1. **`Paths.qml`** - Path management
   - Properties: `home`, `pictures`, `videos`, `config`, `state`, `cache`, `wallsdir`, `recsdir`
   - Functions: `absolutePath()`, `toLocalFile()`, `shortenHome()`
   - Respects XDG Base Directory specification

2. **`Icons.qml`** - Icon utilities
   - Icon name mapping, icon theme support

3. **`Images.qml`** - Image utilities
   - Image loading, caching helpers

4. **`Searcher.qml`** - Search/fuzzy matching
   - Fuzzy search algorithm for launcher

5. **`SysInfo.qml`** - System information
   - Hardware detection, system info queries

**Relationship to other directories:**

- Used BY: All directories (general utilities)
- Does NOT depend on: Other directories (minimal dependencies)

---

## Configuration Files

### `shell.json` - User Settings

**Purpose:** User-editable configuration file for feature toggles and settings.

**Structure:**

```json
{
  "services": {
    /* Service-level settings */
  },
  "appearance": {
    /* Visual settings */
  },
  "general": {
    /* Default applications */
  },
  "bar": {
    /* Bar layout and settings */
  },
  "dashboard": {
    /* Dashboard settings */
  },
  "launcher": {
    /* Launcher actions and settings */
  },
  "session": {
    /* Session menu commands */
  },
  "sidebar": {
    /* Sidebar enabled state */
  },
  "notifs": {
    /* Notification settings */
  },
  "osd": {
    /* OSD settings */
  }
}
```

**Read by:** `config/Config.qml`

**Hot-reload:** Yes - changes are detected and reloaded automatically

**Location:** `~/.config/quickshell/shell.json`

---

### `scheme.json` - Color Scheme

**Purpose:** Defines all colors used in the UI (Material Design 3 tokens).

**Structure:**

```json
{
  "name": "monochrome",
  "flavour": "dark",
  "mode": "dark",
  "variant": "monochrome",
  "colours": {
    "primary": "ffffff",
    "onPrimary": "1a1a1a",
    "surface": "0a0a0a",
    "onSurface": "e8e8e8"
    /* ...100+ color tokens... */
  }
}
```

**Read by:** `services/Colours.qml`

**Hot-reload:** Yes - changes are detected and UI updates automatically

**Location:** `~/.local/state/quickshell/scheme.json` (can also be in config dir)

**Current theme:** Pure monochrome (black/white/grey gradients only)

---

## Data Flow

```
User edits shell.json
         ↓
    Config.qml (FileView + JsonAdapter)
         ↓
    Config.bar, Config.launcher, etc. (typed objects)
         ↓
    modules/ read Config.* properties
         ↓
    modules/ compose components/
         ↓
    components/ read Appearance (from Config) and Colours (from scheme.json)
         ↓
    Rendered UI
```

```
User edits scheme.json
         ↓
    Colours.qml (FileView + JSON parsing)
         ↓
    Colours.palette.m3primary, etc. (reactive properties)
         ↓
    components/ bind to Colours.palette.*
         ↓
    UI colors update automatically
```

```
System event (e.g., window opened in Hyprland)
         ↓
    services/Hypr.qml (receives Hyprland IPC event)
         ↓
    Hypr.toplevels property changes
         ↓
    modules/bar/components/Workspaces.qml (bound to Hypr.workspaces)
         ↓
    Workspace indicator UI updates
```

---

## Import Structure

**QML modules use import aliases defined in qmldir files:**

- `import qs.components` → `components/`
- `import qs.components.controls` → `components/controls/`
- `import qs.components.containers` → `components/containers/`
- `import qs.config` → `config/`
- `import qs.modules.bar` → `modules/bar/`
- `import qs.services` → `services/`
- `import qs.utils` → `utils/`
- `import QShell` → C++ plugin (compiled)
- `import QShell.Audio` → C++ plugin (audio services)
- `import QShell.Hyprland` → C++ plugin (Hyprland extras)
- `import QShell.Models` → C++ plugin (filesystem models)

---

## Component Inventory

### Base Components

**`StyledRect`** - Base themed rectangle

```qml
StyledRect {
    color: Colours.palette.m3surface
    radius: Appearance.rounding.large
}
```

**`StyledText`** - Themed text

```qml
StyledText {
    text: "Hello"
    color: Colours.palette.m3onSurface
    font.pointSize: Appearance.font.size.normal
}
```

**`MaterialIcon`** - Material Design icon

```qml
MaterialIcon {
    text: "settings"  // Icon name
    color: Colours.palette.m3primary
}
```

**`StateLayer`** - Interactive ripple/hover layer

```qml
StateLayer {
    radius: parent.radius
    function onClicked() { /* ... */ }
}
```

### Controls

**`IconButton`** - Icon button with ripple

```qml
IconButton {
    icon: "close"
    onClicked: { /* ... */ }
}
```

**`StyledTextField`** - Text input field

```qml
StyledTextField {
    placeholderText: "Search..."
    onTextChanged: { /* ... */ }
}
```

**`StyledSlider`** - Slider control

```qml
StyledSlider {
    from: 0
    to: 100
    value: 50
    onValueChanged: { /* ... */ }
}
```

**`StyledSwitch`** - Toggle switch

```qml
StyledSwitch {
    checked: true
    onToggled: { /* ... */ }
}
```

### Containers

**`StyledWindow`** - Themed window

```qml
StyledWindow {
    screen: Quickshell.screens[0]
    name: "mywindow"
    // content...
}
```

**`StyledListView`** - Scrollable list

```qml
StyledListView {
    model: myModel
    delegate: StyledText { text: modelData }
}
```

---

## GUI Visual Representations

### Bar (RIGHT SIDE OF THE SCREEN)

```
┌────────────────────────────────────────────────────────────────┐
│ [●] [1][2][3]         Active Window Title        12:45 🔊📶🔋⏻ │
└────────────────────────────────────────────────────────────────┘
 ↑   ↑               ↑                              ↑          ↑
 │   │               │                              │          │
Logo  Workspaces   ActiveWindow                StatusIcons  Power
```

**Components:**

- `OsIcon` - Logo button (toggles launcher)
- `Workspaces` - Hyprland workspace indicators (1-10)
  - Active: filled circle
  - Occupied: outlined circle
  - Empty: dimmed dot
- `ActiveWindow` - Current window title
- `Clock` - Date/time
- `StatusIcons` - Audio (🔊), Network (📶), Battery (🔋), etc.
- `Power` - Power button (toggles session menu)

**Clicking icons opens popouts:**

- Audio icon → Volume slider + device picker
- Network icon → WiFi network list
- Battery icon → Battery status + power profile

---

### Launcher (Bottom Center)

```
                     ┌─────────────┐
                     │   Search    │
                     │ ┌─────────┐ │
                     │ │ text... │ │
                     │ └─────────┘ │
                     │             │
                     │ [📱 App 1 ] │
                     │ [📱 App 2 ] │
                     │ [📱 App 3 ] │
                     │ [⚙  Action] │
                     └─────────────┘
```

**Components:**

- `StyledTextField` - Search input
- `ContentList` - Scrollable result list
  - `AppItem` - Application entries with icon, name, description
  - `ActionItem` - System actions (shutdown, reboot, lock, etc.)
  - `CalcItem` - Calculator results (if query is math)
  - `SchemeItem`, `VariantItem` - Theme pickers
  - `WallpaperItem` - Wallpaper thumbnails

**Activation:**

- Click logo or press Super key
- Type to filter
- Arrow keys to navigate, Enter to launch
- Prefix `>` for actions, `@` for special modes

---

### Dashboard (Top Center Pulldown)

```
        ┌────────────────────────────────┐
        │  [Dash] [Media] [Performance]  │ ← Tabs
        ├────────────────────────────────┤
        │  ╔════════════════════════╗    │
        │  ║    Friday, Jan 10      ║    │
        │  ║       14:30:45         ║    │
        │  ╚════════════════════════╝    │
        │                                │
        │  ┌─ Calendar ─────────────┐   │
        │  │ S M T W T F S          │   │
        │  │ 1 2 3 4 5 6 7          │   │
        │  │ ...                    │   │
        │  └────────────────────────┘   │
        │                                │
        │  User: username                │
        │  Uptime: 2h 34m               │
        └────────────────────────────────┘
```

**Tabs:**

1. **Dash** - Date/time, calendar, user info, resources
2. **Media** - Media player controls, album art, playback progress
3. **Performance** - CPU/RAM/disk usage graphs

**Components:**

- `Tabs.qml` - Tab navigation
- `dash/DateTime.qml` - Large date/time display
- `dash/Calendar.qml` - Month calendar
- `dash/User.qml` - User profile, uptime
- `dash/Media.qml` - Media player with progress ring
- `dash/Resources.qml` - System usage graphs

---

### Session Menu (Center)

```
             ┌──────────────┐
             │              │
             │   [LOGOUT]   │
             │              │
             │  [SHUTDOWN]  │
             │              │
             │  [HIBERNATE] │
             │              │
             │   [REBOOT]   │
             │              │
             └──────────────┘
```

**Components:**

- `SessionButton` - Large icon buttons
  - Logout (exit_to_app)
  - Shutdown (power_settings_new)
  - Hibernate (downloading)
  - Reboot (cached)

**Activation:**

- Click power button in bar
- Keyboard navigation (arrows, vim keybinds if enabled)
- Enter to execute, Escape to cancel

---

### Sidebar (Right - Notification Center)

```
                               ┌──────────────┐
                               │ Notifications│
                               ├──────────────┤
                               │ ╔══════════╗ │
                               │ ║ Spotify  ║ │
                               │ ║ Now Play ║ │
                               │ ╚══════════╝ │
                               │              │
                               │ ╔══════════╗ │
                               │ ║ System   ║ │
                               │ ║ Update   ║ │
                               │ ╚══════════╝ │
                               │              │
                               │ [Clear All]  │
                               └──────────────┘
```

**Components:**

- `NotifGroup.qml` - Grouped notifications by app
- `Notif.qml` - Individual notification with icon, title, body, actions
- Clear all button

**Activation:**

- Click notification icon in bar
- IPC: `qs ipc call drawers toggle sidebar`
- Hyprland bind: `bind = SUPER, N, exec, qs ipc call drawers toggle sidebar`

---

### OSD (Center Right)

```
                            ┌──────────┐
                            │    🔊    │
                            │ ████████ │ ← Progress bar
                            │   75%    │
                            └──────────┘
```

**Components:**

- `CircularProgress` or `FilledSlider` - Visual indicator
- `MaterialIcon` - Icon for type (volume, brightness, etc.)
- Auto-hides after 2 seconds (configurable)

**Triggers:**

- Volume up/down keys
- Brightness up/down keys
- Media keys

---

### Notification Popup (Top Right)

```
                               ┌──────────────┐
                               │ [icon] Title │
                               │              │
                               │ Message body │
                               │ goes here... │
                               │              │
                               │ [Action] [X] │
                               └──────────────┘
```

**Components:**

- `Notification.qml` - Popup notification
  - App icon
  - Title, body text
  - Action buttons
  - Dismiss button
  - Auto-expires (if enabled)

---

## Summary of Relationships

```
shell.json ──────┬──────→ config/Config.qml ────→ modules/ (read settings)
                 │                                       ↓
scheme.json ─────┼──────→ services/Colours.qml          ↓
                 │                ↓                      ↓
                 └──────→ config/Appearance.qml         ↓
                                  ↓                      ↓
                         components/ ←──────────────────┘
                         (compose UI)
                                  ↓
services/Hypr.qml ────────────────┼──────→ modules/ (bind to state)
services/Audio.qml ───────────────┤
services/Network.qml ─────────────┤
etc. ─────────────────────────────┘

utils/Paths.qml ──────────────────────────→ Everyone (path resolution)
utils/Icons.qml ──────────────────────────→ components/ (icon lookup)
```

**Key principles:**

1. **Unidirectional data flow:** shell.json → Config → modules → components
2. **Reactive bindings:** Services emit property changes, modules react
3. **Separation of concerns:**
   - Components: presentation only
   - Config: settings only
   - Services: state and system integration
   - Modules: feature composition
   - Utils: helper functions

4. **Theming:** All colors from scheme.json, all visual settings from Appearance
5. **Hot-reload:** Changes to shell.json and scheme.json reload automatically

---

## Development Workflow

**To add a new feature:**

1. Create component in `components/` (if needed)
   - Use `Colours.palette.*` for colors
   - Use `Appearance.*` for spacing/fonts/animations

2. Create config object in `config/` (if settings needed)
   - Add properties with defaults
   - Import in `Config.qml`

3. Create module in `modules/`
   - Import components, config, services
   - Compose UI
   - Create `Wrapper.qml` for layout positioning

4. Update `shell.json` with default settings

5. Import module in `shell.qml` or appropriate parent module

**To modify styling:**

1. Edit `scheme.json` to change colors
2. Edit `shell.json` → `appearance` section to change spacing/fonts/animations
3. Changes apply automatically (hot-reload)

**To add a service:**

1. Create singleton in `services/`
2. Implement properties (reactive state)
3. Implement functions (actions)
4. Import in modules that need it

---

## File Naming Conventions

- `*Config.qml` - Configuration objects (read from shell.json)
- `Styled*.qml` - Themed components (read from Appearance/Colours)
- `*Wrapper.qml` - Layout wrappers for modules
- `*Background.qml` - Background rendering for modules
- `*Content.qml` - Main content area for modules
- Singleton files: `pragma Singleton` directive at top
