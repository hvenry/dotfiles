#!/bin/bash

# Display battery status with icon
# Returns format: "󰁹  85%" or "󰂄  100%" when charging

# Check if battery exists
if [ ! -d "/sys/class/power_supply/BAT0" ] && [ ! -d "/sys/class/power_supply/BAT1" ]; then
  echo ""
  exit 0
fi

# Find the battery (BAT0 or BAT1)
if [ -d "/sys/class/power_supply/BAT0" ]; then
  battery_path="/sys/class/power_supply/BAT0"
elif [ -d "/sys/class/power_supply/BAT1" ]; then
  battery_path="/sys/class/power_supply/BAT1"
else
  echo ""
  exit 0
fi

# Get battery percentage
capacity=$(cat "$battery_path/capacity" 2>/dev/null)
status=$(cat "$battery_path/status" 2>/dev/null)

if [ -z "$capacity" ]; then
  echo "󰁹  ?%"
  exit 0
fi

# Choose icon based on status and capacity
if [ "$status" = "Charging" ]; then
  echo "󰂄  ${capacity}%"
elif [ "$capacity" -ge 75 ]; then
  echo "󰂁  ${capacity}%"
elif [ "$capacity" -ge 50 ]; then
  echo "󰁾  ${capacity}%"
elif [ "$capacity" -ge 25 ]; then
  echo "󰁻  ${capacity}%"
else
  echo "󰁺  ${capacity}%"
fi
