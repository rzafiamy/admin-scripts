# Upgradable Packages Script

## Overview
This Bash script lists all upgradable packages on a Debian-based Linux system in a **user-friendly table format**. It automatically detects the system language (**English or French**) and adjusts the display accordingly.

## Features
- 🛠 **Automatic Language Detection**: Supports English 🇬🇧 and French 🇫🇷.
- 📦 **Lists Upgradable Packages**: Displays package name, current version, new version, and architecture.
- 🚀 **Easy-to-Read Table Format**.
- 🔄 **Suggests Upgrade Command**: Provides an easy-to-execute upgrade command.

## Prerequisites
- A **Debian-based** system (Ubuntu, Debian, etc.).
- Run the script with **root (sudo) privileges**.
- `apt` package manager should be available.

## Installation
1. Clone or download the script:
   ```bash
   git clone https://github.com/rzafiamy/admin-scripts.git
   cd admin-scripts/tools
   ```
2. Give execution permissions:
   ```bash
   chmod +x upgradable_packages.sh
   ```

## Usage
Run the script using:
```bash
sudo ./upgradable_packages.sh
```

### Example Output (English):
```
📦 List of upgradable packages:

Package Name             Current Version       New Version           Architecture
--------------------------------------------------------------------------------
ubuntu-release-upgrader-core  1:20.04.31          1:20.04.41            all      
apt                          2.0.5               2.0.10                amd64    

🔄 To upgrade all packages, run: sudo apt upgrade -y
```

### Example Output (French):
```
📦 Liste des paquets pouvant être mis à jour :

Nom du paquet             Version actuelle       Nouvelle version      Architecture
--------------------------------------------------------------------------------
ubuntu-release-upgrader-core  1:20.04.31          1:20.04.41            all      
apt                          2.0.5               2.0.10                amd64    

🔄 Pour mettre à jour tous les paquets, exécutez : sudo apt upgrade -y
```

## Notes
- If no updates are available, the script will display: `No updates available.` (or `Aucune mise à jour disponible.` in French).
- The script **does not install updates**, it only lists them.

## License
This project is licensed under the Apache 2.0 License.

## Contributing
Feel free to submit issues or pull requests to enhance the script!