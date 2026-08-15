#!/bin/bash

# Source the machine-specific config
source "$(dirname "$0")/.local"

# Export the variable so envsubst can use it
export PRIMARY_MONITOR

# Process the config with envsubst and start waybar
envsubst <~/.config/waybar/config.jsonc | waybar -c /dev/stdin
