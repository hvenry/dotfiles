# .zprofile Runs once at the start of a login shell, sets session-wide environment variables
# .zshrc runs every time we start an interactive shell

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Set session environment variables
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland

# Start Hyprland automatically if launched from ly
if [ -z "$DISPLAY" ] && [ "${XDG_VTNR:-1}" -eq 1 ]; then
  exec Hyprland
fi
