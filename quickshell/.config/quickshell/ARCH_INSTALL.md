# Arch Linux Installation Guide

This document provides detailed instructions for installing quickshell and its custom QML plugins on Arch Linux, including solutions to common dependency issues.

## Prerequisites

### System Requirements

- Arch Linux (up-to-date)
- `yay` or another AUR helper installed
- sudo access

## Installation Steps

### 1. Clear Old Build Artifacts and Caches

Before starting, clean any existing quickshell data:

```bash
rm -rf ~/.cache/quickshell ~/.local/state/quickshell
rm -rf ~/dotfiles/quickshell/.config/quickshell/build
```

### 2. Install Runtime Dependencies

#### From Official Repositories

```bash
sudo pacman -S --needed \
  hyprland \
  hyprpaper \
  brightnessctl \
  networkmanager \
  pipewire \
  qt6-declarative \
  qt6-base \
  ttf-cascadia-code-nerd
```

#### From AUR

Install Material Symbols font:

```bash
yay -S --needed ttf-material-symbols-variable-git
```

### 3. Install Build Dependencies

```bash
sudo pacman -S --needed cmake ninja gcc libqalculate
yay -S --needed libcava
```

**Important:** You need `libcava`, not just `cava`. The `libcava` package provides the shared library required for audio visualization.

### 4. Install quickshell-git (with LTO Fix)

Due to an LTO version mismatch between GCC 15 and the `google-breakpad` library, you need to disable crash reporting when building quickshell-git.

#### Option A: Manual PKGBUILD Modification

1. Download the PKGBUILD:

   ```bash
   yay -G quickshell-git
   cd quickshell-git
   ```

2. Edit the `PKGBUILD`:

   ```bash
   nvim PKGBUILD
   ```

3. Make these changes:
   - Remove `'google-breakpad'` from the `depends` array
   - Add `-DCRASH_REPORTER=OFF` to the cmake command:
     ```bash
     cmake -GNinja -B build \
       -DCMAKE_BUILD_TYPE="RelWithDebInfo" \
       -DCMAKE_INSTALL_PREFIX=/usr \
       -DDISTRIBUTOR="AUR (package: quickshell-git)" \
       -DDISTRIBUTOR_DEBUGINFO_AVAILABLE=NO \
       -DINSTALL_QML_PREFIX=lib/qt6/qml \
       -DCRASH_REPORTER=OFF
     ```

4. Build and install:
   ```bash
   makepkg -si
   ```

#### Option B: Use Pre-Modified PKGBUILD

If available, use the modified PKGBUILD from `~/dotfiles/quickshell/arch/` (if you create one for future use).

### 5. Build Custom QML Plugins

This configuration requires custom QML plugins for calculator, audio visualization, Hyprland integration, and file models.

```bash
cd ~/dotfiles/quickshell/.config/quickshell

# Clean any existing build
rm -rf build

# Configure with CMake
cmake -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/ \
  -DVERSION=1.0.0 \
  -DGIT_REVISION=refactored \
  -DENABLE_MODULES="plugin;shell"

# Build the plugins
cmake --build build
```

### 6. Install Plugins to System

```bash
sudo cmake --install build
```

This installs:

- Custom QML plugins to `/usr/lib/qt6/qml/Utils/`
  - `Utils` - Core utilities (calculator, HTTP requests, toast notifications)
  - `Utils.Audio` - Audio collector and Cava visualizer
  - `Utils.Hyprland` - Hyprland keyboard state, image caching, circular indicators
  - `Utils.Models` - Filesystem models for file dialogs
- Shell configuration to `/etc/xdg/quickshell/` (will be overridden by stow)

### 7. Stow the Configuration

```bash
cd ~/dotfiles
stow quickshell
```

This creates symlinks from `~/.config/quickshell/` to your dotfiles repo.

### 8. Launch Quickshell

#### Manual Test

```bash
quickshell -c ~/.config/quickshell
```

Or using the short command:

```bash
qs -c ~/.config/quickshell
```

#### Auto-start with Hyprland

Add to `~/.config/hypr/hyprland.conf`:

```conf
exec-once = qs -c ~/.config/quickshell
```

## Common Issues and Solutions

### Issue: "Package 'cava' not found"

**Solution:** Install `libcava` instead of (or in addition to) `cava`:

```bash
yay -S --needed libcava
```

The `cava` package only provides the CLI tool, while `libcava` provides the shared library needed for the audio visualizer plugin.

### Issue: quickshell-git fails with "LTO version mismatch"

**Error:**

```
lto1: fatal error: bytecode stream in file 'libbreakpad_client.a'
generated with LTO version 14.0 instead of the expected 15.1
```

**Solution:** Disable crash reporter by adding `-DCRASH_REPORTER=OFF` to the cmake configuration in the quickshell-git PKGBUILD (see step 4 above).

### Issue: Missing Material Symbols icons

**Solution:** Install the variable font version:

```bash
yay -S --needed ttf-material-symbols-variable-git
```

### Issue: Custom QML plugins not found

**Symptoms:** Errors like `module "Utils" is not installed` or `module "Utils.Audio" is not installed`

**Solution:**

1. Verify plugins are installed:

   ```bash
   ls -la /usr/lib/qt6/qml/Utils/
   ```

2. Rebuild and reinstall plugins:
   ```bash
   cd ~/dotfiles/quickshell/.config/quickshell
   rm -rf build
   cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/ -DVERSION=1.0.0 -DENABLE_MODULES="plugin;shell"
   cmake --build build
   sudo cmake --install build
   ```

### Issue: Build fails with missing Qt dependencies

**Solution:** Ensure you have the required Qt6 packages:

```bash
sudo pacman -S --needed qt6-declarative qt6-base qt6-svg
```

## Updating

### Update quickshell-git

```bash
yay -S quickshell-git
```

If you encounter the LTO issue again, you'll need to reapply the PKGBUILD modifications.

### Update Custom Plugins

After pulling changes from the dotfiles repo:

```bash
cd ~/dotfiles/quickshell/.config/quickshell
cmake --build build
sudo cmake --install build
qs -r  # Reload quickshell
```

### Update Configuration Only

```bash
cd ~/dotfiles
git pull
stow -R quickshell  # Restow to update symlinks
qs -r  # Reload quickshell
```

## Uninstalling

### Remove Custom Plugins

```bash
sudo rm -rf /usr/lib/qt6/qml/Utils
```

### Remove Configuration

```bash
cd ~/dotfiles
stow -D quickshell
rm -rf ~/.config/quickshell
rm -rf ~/.cache/quickshell ~/.local/state/quickshell
```

### Remove quickshell-git

```bash
sudo pacman -R quickshell-git
```

## Dependencies Summary

### Required Packages

| Package                             | Source   | Purpose                     |
| ----------------------------------- | -------- | --------------------------- |
| `quickshell-git`                    | AUR      | Main quickshell application |
| `hyprland`                          | Official | Wayland compositor          |
| `hyprpaper`                         | Official | Wallpaper daemon            |
| `brightnessctl`                     | Official | Brightness control          |
| `networkmanager`                    | Official | Network management          |
| `pipewire`                          | Official | Audio system                |
| `qt6-declarative`                   | Official | Qt QML runtime              |
| `qt6-base`                          | Official | Qt base libraries           |
| `ttf-cascadia-code-nerd`            | Official | Monospace font              |
| `ttf-material-symbols-variable-git` | AUR      | Icon font                   |
| `cmake`                             | Official | Build system                |
| `ninja`                             | Official | Build tool                  |
| `gcc`                               | Official | C++ compiler                |
| `libqalculate`                      | Official | Calculator library          |
| `libcava`                           | AUR      | Audio visualizer library    |

### Optional Packages

| Package      | Source   | Purpose                     |
| ------------ | -------- | --------------------------- |
| `ddcutil`    | Official | External monitor brightness |
| `lm-sensors` | Official | Temperature monitoring      |

## Troubleshooting

### Enable Debug Output

Run quickshell with verbose logging:

```bash
QT_LOGGING_RULES="*.debug=true" qs -c ~/.config/quickshell
```

### Check Plugin Loading

Verify QML module paths:

```bash
qml -c "import Utils 1.0"
```

### Rebuild Everything from Scratch

Complete clean rebuild:

```bash
# Clean quickshell data
rm -rf ~/.cache/quickshell ~/.local/state/quickshell

# Clean build artifacts
cd ~/dotfiles/quickshell/.config/quickshell
rm -rf build

# Remove installed plugins
sudo rm -rf /usr/lib/qt6/qml/Utils

# Rebuild and reinstall
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/ -DVERSION=1.0.0 -DENABLE_MODULES="plugin;shell"
cmake --build build
sudo cmake --install build

# Restow configuration
cd ~/dotfiles
stow -R quickshell
```
