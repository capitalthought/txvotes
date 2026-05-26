#!/usr/bin/env bash
# txvotes status line — Midnight Sapphire theme 🗳️
# Colors: 69 sapphire / 111 periwinkle / 159 ice / 61 indigo / 60 twilight

input=$(cat)

# Set whole terminal window background via OSC 11
printf "\033]11;#040428\033\\"

# ANSI colors (256-color)
RESET="\033[0m"
PRIMARY="\033[38;5;69m"          # sapphire
SECONDARY="\033[38;5;111m"       # periwinkle
BRANCH_COLOR="\033[38;5;159m"    # ice
ACCENT="\033[38;5;61m"           # indigo
MUTED="\033[38;5;60m"            # twilight
BOLD="\033[1m"
BG_BAR="\033[48;5;18m"           # bar background

# Extract fields
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "?"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
session=$(echo "$input" | jq -r '.session_name // empty')

# Git branch
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)

# Shorten path
short_path=$(echo "$cwd" | awk -F/ '{
  n=NF
  if (n >= 2) print $(n-1)"/"$n
  else print $n
}')

# Context bar
ctx_segment=""
if [ -n "$used_pct" ]; then
  filled=$(echo "$used_pct" | awk '{printf "%d", ($1/100)*5 + 0.5}')
  bar=""
  for i in 1 2 3 4 5; do
    if [ "$i" -le "$filled" ]; then bar="${bar}█"; else bar="${bar}░"; fi
  done
  pct_int=$(printf "%.0f" "$used_pct")
  ctx_segment=$(printf "${MUTED}ctx${RESET}${MUTED}[${bar}${pct_int}%%]${RESET}")
fi

# Session
session_segment=""
if [ -n "$session" ]; then
  session_segment=$(printf " ${ACCENT}✨${session}${RESET}")
fi

# Branch
branch_segment=""
if [ -n "$branch" ]; then
  branch_segment=$(printf " ${BRANCH_COLOR}⎇ ${branch}${RESET}")
fi

# Assemble
printf "${BG_BAR}${BOLD}${PRIMARY} 🗳️ txvotes${RESET}"
printf "${BG_BAR}${SECONDARY} /${short_path}${RESET}"
printf "${BG_BAR}${branch_segment}${RESET}"
printf "${BG_BAR}${session_segment}${RESET}"
printf "${BG_BAR} ${ACCENT}⚡${model}${RESET}"
[ -n "$ctx_segment" ] && printf "${BG_BAR} ${ctx_segment}${RESET}"
printf "${BG_BAR} ${RESET}\n"
