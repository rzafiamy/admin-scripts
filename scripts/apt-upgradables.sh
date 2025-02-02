#!/bin/bash

# Ensure the script is run with superuser privileges
if [[ $EUID -ne 0 ]]; then
    echo "Please run as root (sudo) for accurate upgrade information."
    exit 1
fi

# Detect system language
LANGUAGE=$(locale | grep LANG= | cut -d= -f2 | cut -d_ -f1)

# Define text translations
if [[ "$LANGUAGE" == "fr" ]]; then
    MSG_NO_UPDATES="Aucune mise à jour disponible."
    MSG_UPDATES="📦 Liste des paquets pouvant être mis à jour :"
    MSG_PACKAGE_NAME="Nom du paquet"
    MSG_CURRENT_VERSION="Version actuelle"
    MSG_NEW_VERSION="Nouvelle version"
    MSG_ARCH="Architecture"
    MSG_UPDATE_COMMAND="🔄 Pour mettre à jour tous les paquets, exécutez : sudo apt upgrade -y"
    SEARCH_TERM="pouvant être mis à jour depuis"
else
    MSG_NO_UPDATES="No updates available."
    MSG_UPDATES="📦 List of upgradable packages:"
    MSG_PACKAGE_NAME="Package Name"
    MSG_CURRENT_VERSION="Current Version"
    MSG_NEW_VERSION="New Version"
    MSG_ARCH="Architecture"
    MSG_UPDATE_COMMAND="🔄 To upgrade all packages, run: sudo apt upgrade -y"
    SEARCH_TERM="upgradable from"
fi

# Update package list
apt update -qq

# Get upgradable packages
upgradable_packages=$(apt list --upgradable 2>/dev/null)

# Check if updates are available
if [[ -z "$upgradable_packages" ]]; then
    echo "$MSG_NO_UPDATES"
    exit 0
fi

# Print table header
echo -e "\n$MSG_UPDATES\n"
echo -e "$MSG_PACKAGE_NAME\t\t$MSG_CURRENT_VERSION\t$MSG_NEW_VERSION\t$MSG_ARCH"
echo "-------------------------------------------------------------------------------"

# Parse and format the package list
apt list --upgradable 2>/dev/null | grep "$SEARCH_TERM" | awk '
{
    match($0, /([a-zA-Z0-9-]+)\/[^ ]+ ([^ ]+) ([a-z]+) \[.*: ([^ ]+)\]/, arr);
    if (arr[1] != "") {
        printf "%-40s %-20s %-20s %-10s\n", arr[1], arr[4], arr[2], arr[3];
    }
}'

# Print final message
echo -e "\n$MSG_UPDATE_COMMAND"

