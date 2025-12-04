#!/usr/bin/env bash

# ---------------------------------------
#  Fancy wget downloader
# ---------------------------------------

URL="$1"

if [[ -z "$URL" ]]; then
    echo -e "\e[91m[ERROR]\e[0m No URL provided."
    echo -e "Usage: $0 <url>"
    exit 1
fi

# Colors
CYAN="\e[96m"
GREEN="\e[92m"
YELLOW="\e[93m"
RESET="\e[0m"
BOLD="\e[1m"

# Header
clear
echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════╗"
echo "║              WGET SUPER-DOWNLOADER           ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${RESET}"

echo -e "${YELLOW}Preparing download...${RESET}"
sleep 0.5

# Show pretty URL info
echo -e "${GREEN}→ Target:${RESET} $URL"
echo ""

# Spinner while checking URL
echo -ne "${CYAN}Checking connection "
spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
for i in {1..18}; do
    printf "\b${spin:i%${#spin}:1}"
    sleep 0.08
done
echo -e "${RESET}"
sleep 0.3

echo -e "${GREEN}✓ Starting download...${RESET}"
echo ""

# Run wget with all provided flags
wget -c -q --show-progress \
     --timeout=10 \
     --tries=3 \
     --dns-timeout=5 \
     --connect-timeout=5 \
     --read-timeout=10 \
     --limit-rate=0 \
     --no-if-modified-since \
     --retry-connrefused \
     "$URL"

# Final message
if [[ $? -eq 0 ]]; then
    echo -e "\n${GREEN}${BOLD}✔ Download completed successfully!${RESET}"
else
    echo -e "\n${RED}${BOLD}✘ Download failed.${RESET}"
fi
