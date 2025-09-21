#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILES_DIR="$DOTFILES_DIR/profiles"

# Function to remove existing configurations
remove_existing_configs() {
    local packages="$1"
    echo "Checking for existing configurations to remove..."
    echo ""
    
    for package in $packages; do
        case "$package" in
            "zsh")
                if [ -f ~/.zshrc ] || [ -f ~/.p10k.zsh ]; then
                    echo "Removing existing zsh configs..."
                    rm -f ~/.zshrc ~/.p10k.zsh
                fi
                ;;
            "nvim")
                if [ -d ~/.config/nvim ]; then
                    echo "Removing existing nvim config..."
                    rm -rf ~/.config/nvim
                fi
                ;;
            "tmux")
                if [ -d ~/.config/tmux ] || [ -f ~/.tmux.conf ]; then
                    echo "Removing existing tmux configs..."
                    rm -rf ~/.config/tmux ~/.tmux.conf
                fi
                ;;
            "ghostty")
                if [ -d ~/.config/ghostty ]; then
                    echo "Removing existing ghostty config..."
                    rm -rf ~/.config/ghostty
                fi
                ;;
            "vscode")
                # Cross-platform VS Code config removal
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    # macOS
                    if [ -d ~/Library/Application\ Support/Code/User ]; then
                        echo "Removing existing VS Code config (macOS)..."
                        rm -rf ~/Library/Application\ Support/Code/User
                    fi
                elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                    # Linux
                    if [ -d ~/.config/Code/User ]; then
                        echo "Removing existing VS Code config (Linux)..."
                        rm -rf ~/.config/Code/User
                    fi
                else
                    echo "Warning: Unknown OS type for VS Code config removal"
                fi
                ;;
            "hyprland")
                if [ -d ~/.config/hypr ]; then
                    echo "Removing existing hyprland config..."
                    rm -rf ~/.config/hypr
                fi
                ;;
            "waybar")
                if [ -d ~/.config/waybar ]; then
                    echo "Removing existing waybar config..."
                    rm -rf ~/.config/waybar
                fi
                ;;
            "wofi")
                if [ -d ~/.config/wofi ]; then
                    echo "Removing existing wofi config..."
                    rm -rf ~/.config/wofi
                fi
                ;;
            "eww")
                if [ -d ~/.config/eww ]; then
                    echo "Removing existing eww config..."
                    rm -rf ~/.config/eww
                fi
                ;;
            "mako")
                if [ -d ~/.config/mako ]; then
                    echo "Removing existing mako config..."
                    rm -rf ~/.config/mako
                fi
                ;;
            "swww")
                if [ -d ~/.config/swww ]; then
                    echo "Removing existing swww config..."
                    rm -rf ~/.config/swww
                fi
                ;;
            "sddm")
                echo "Note: SDDM config removal requires sudo and affects system-wide settings"
                echo "Skipping automatic removal for sddm - please handle manually if needed"
                ;;
        esac
    done
    echo ""
}

show_usage() {
    echo "Usage: $0 [--clean] <profile-name>"
    echo ""
    echo "Options:"
    echo "  --clean    Remove existing configurations before installing"
    echo ""
    echo "Available profiles:"
    for profile in "$PROFILES_DIR"/*.txt; do
        if [ -f "$profile" ]; then
            basename "$profile" .txt | sed 's/^/  /'
        fi
    done
    echo ""
    echo "Examples:"
    echo "  $0 macos              # Install macOS profile (keep existing configs)"
    echo "  $0 --clean macos      # Remove existing configs, then install macOS profile"
    echo "  $0 arch-hyprland      # Install Arch Linux + Hyprland profile"
    echo "  $0 server             # Install server profile"
}

if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

# Parse arguments
CLEAN_MODE=false
PROFILE_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            CLEAN_MODE=true
            shift
            ;;
        -*)
            echo "Error: Unknown option $1"
            echo ""
            show_usage
            exit 1
            ;;
        *)
            if [ -z "$PROFILE_NAME" ]; then
                PROFILE_NAME="$1"
            else
                echo "Error: Multiple profile names provided"
                echo ""
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$PROFILE_NAME" ]; then
    echo "Error: No profile name provided"
    echo ""
    show_usage
    exit 1
fi

PROFILE_FILE="$PROFILES_DIR/$PROFILE_NAME.txt"

if [ ! -f "$PROFILE_FILE" ]; then
    echo "Error: Profile '$PROFILE_NAME' not found!"
    echo ""
    show_usage
    exit 1
fi

echo "Installing profile: $PROFILE_NAME"
echo "Profile file: $PROFILE_FILE"
echo ""

# Extract packages from profile file (ignore comments and empty lines)
PACKAGES=$(grep -v '^#' "$PROFILE_FILE" | grep -v '^$' | tr '\n' ' ')

if [ -z "$PACKAGES" ]; then
    echo "Error: No packages found in profile!"
    exit 1
fi

echo "Packages to install: $PACKAGES"
echo ""

# Remove existing configurations if --clean flag is used
if [ "$CLEAN_MODE" = true ]; then
    echo "🧹 Clean mode enabled - removing existing configurations..."
    remove_existing_configs "$PACKAGES"
fi

# Change to dotfiles directory
cd "$DOTFILES_DIR"

# Install packages using stow
for package in $PACKAGES; do
    if [ -d "$package" ]; then
        echo "Installing package: $package"
        stow "$package"
    else
        echo "Warning: Package directory '$package' not found, skipping..."
    fi
done

echo ""
echo "Profile '$PROFILE_NAME' installed successfully!"
