#!/bin/bash

# Display network connection status with icon
# Returns format: "  WiFi" or "󰈀  Wired" or "󰤮  Offline"

# Check for active connections
wifi_status=""
ethernet_status=""

# Check WiFi using nmcli (NetworkManager)
if command -v nmcli &>/dev/null; then
  wifi_status=$(nmcli -t -f TYPE,STATE device | grep "^wifi:" | grep ":connected$")
  ethernet_status=$(nmcli -t -f TYPE,STATE device | grep "^ethernet:" | grep ":connected$")
fi

# Check if connected to WiFi
if [ -n "$wifi_status" ]; then
  # Get WiFi network name
  if command -v nmcli &>/dev/null; then
    ssid=$(nmcli -t -f active,ssid dev wifi | grep "^yes:" | cut -d: -f2)
    if [ -n "$ssid" ]; then
      echo "  $ssid"
    else
      echo "  WiFi"
    fi
  else
    echo "  WiFi"
  fi
# Check if connected via Ethernet
elif [ -n "$ethernet_status" ]; then
  echo "󰈀  Wired"
# Fallback: check if we can reach the internet
elif ping -c 1 8.8.8.8 &>/dev/null; then
  echo "󰈀  Online"
else
  echo "󰤮  Offline"
fi
