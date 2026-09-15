#!/bin/bash

# Claude Code Status Line Script
# Reads JSON input from stdin and outputs a formatted status line

input=$(cat)

current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
model_name=$(echo "$input" | jq -r '.model.display_name')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Format token counts (e.g., 15234 -> 15.2k, 1234567 -> 1.2m)
format_tokens() {
    local n=$1
    if [ "$n" -ge 1000000 ]; then
        printf "%.1fm" "$(echo "scale=1; $n / 1000000" | bc)"
    elif [ "$n" -ge 1000 ]; then
        printf "%.1fk" "$(echo "scale=1; $n / 1000" | bc)"
    else
        printf "%d" "$n"
    fi
}

# Get color code based on usage percentage
# green <50%, yellow 50-79%, red >=80%
get_color() {
    local pct=$1
    if [ "$(echo "$pct >= 80" | bc)" -eq 1 ]; then
        printf "\033[31m"  # red
    elif [ "$(echo "$pct >= 50" | bc)" -eq 1 ]; then
        printf "\033[33m"  # yellow
    else
        printf "\033[32m"  # green
    fi
}

# Build a visual bar: ████░░░░░░
usage_bar() {
    local pct=$1
    local width=10
    local filled=$(printf "%.0f" "$(echo "scale=1; $pct * $width / 100" | bc)")
    if [ "$filled" -gt "$width" ]; then filled=$width; fi
    if [ "$filled" -lt 0 ]; then filled=0; fi
    local empty=$((width - filled))

    local bar=""
    for ((i = 0; i < filled; i++)); do bar+="█"; done
    for ((i = 0; i < empty; i++)); do bar+="░"; done

    local color
    color=$(get_color "$pct")

    printf "%b%s\033[0m" "$color" "$bar"
}

# Current directory
short_dir=$(basename "$current_dir")

# Derive used tokens from percentage and context size (matches /context output)
used_tokens=$(printf "%.0f" "$(echo "scale=0; $context_size * ${used_pct:-0} / 100" | bc)")
used_fmt=$(format_tokens "$used_tokens")
ctx_fmt=$(format_tokens "$context_size")

# Build output: dir [model] ████░░░░░░ 42% 38.5k/200k
# Orange = \033[38;5;208m
if [ -n "$used_pct" ]; then
    bar=$(usage_bar "$used_pct")
    pct_color=$(get_color "$used_pct")
    pct_rounded=$(printf "%.0f" "$used_pct")
    printf "\033[34m%s\033[0m \033[38;5;208m[%s]\033[0m %b %b%s%%\033[0m \033[38;5;245m%s/%s\033[0m \033[32m+%s\033[0m \033[31m-%s\033[0m" \
        "$short_dir" "$model_name" "$bar" "$pct_color" "$pct_rounded" "$used_fmt" "$ctx_fmt" "$lines_added" "$lines_removed"
else
    printf "\033[34m%s\033[0m \033[38;5;208m[%s]\033[0m \033[38;5;245m%s/%s\033[0m \033[32m+%s\033[0m \033[31m-%s\033[0m" \
        "$short_dir" "$model_name" "$used_fmt" "$ctx_fmt" "$lines_added" "$lines_removed"
fi
