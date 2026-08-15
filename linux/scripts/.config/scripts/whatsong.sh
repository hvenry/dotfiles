#!/bin/bash

# Get current playing song from any media player using playerctl
# Returns format: "Artist - Song" or "No music playing"

# Check if playerctl is available
if ! command -v playerctl &>/dev/null; then
  echo ""
  exit 0
fi

# Get the current status from any available player
status=$(playerctl -a status 2>/dev/null | head -n1)

if [ "$status" = "Playing" ]; then
  # Get artist and title from the currently playing player
  artist=$(playerctl -a metadata artist 2>/dev/null | head -n1)
  title=$(playerctl -a metadata title 2>/dev/null | head -n1)

  if [ -n "$artist" ] && [ -n "$title" ]; then
    # Limit length to avoid overflow on lock screen
    output="$artist - $title"
    if [ ${#output} -gt 50 ]; then
      # Truncate if too long
      echo "󰲸  ${output:0:47}..."
    else
      echo "󰲸  $output"
    fi
  elif [ -n "$title" ]; then
    # Just title if no artist
    if [ ${#title} -gt 50 ]; then
      echo "${title:0:47}..."
    else
      echo "$title"
    fi
  else
    echo "Playing"
  fi
elif [ "$status" = "Paused" ]; then
  # Show paused song info
  artist=$(playerctl -a metadata artist 2>/dev/null | head -n1)
  title=$(playerctl -a metadata title 2>/dev/null | head -n1)

  if [ -n "$artist" ] && [ -n "$title" ]; then
    echo "󰐊  $artist - $title"
  elif [ -n "$title" ]; then
    echo "󰐊  $title"
  else
    echo "Paused"
  fi
else
  echo ""
fi
