# Setup Local Environment

A comprehensive Linux development environment setup script that automates the installation and configuration of various tools, applications, and utilities commonly needed for development work.

## Overview

This repository provides a streamlined way to set up a complete development environment on a fresh Linux installation. It installs essential development tools, modern terminal configurations, popular applications, and productivity utilities in a single automated process.

## Features

- **Automated Installation**: One-command setup for entire development environment
- **Comprehensive Tool Selection**: Includes development tools, IDEs, browsers, and productivity apps
- **Modern Terminal Setup**: Zsh shell with Starship prompt and Zap plugin manager
- **Version Management**: Mise for managing multiple language versions
- **Container Support**: Docker installation included
- **Desktop Integration**: Creates desktop applications for web services

## Prerequisites

- Linux system (Ubuntu/Debian-based recommended)
- Root/sudo access
- Internet connection

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd setup-local-env
   ```

2. Make the installation script executable:
   ```bash
   chmod +x install.sh
   ```

3. Run the installation script as root:
   ```bash
   sudo ./install.sh
   ```

## What Gets Installed

The script installs the following components in order:

### System & Core Tools
- **System Updates** - Updates package lists and upgrades system packages
- **Essential Packages** - Core development tools, libraries, databases, and utilities
- **Fonts** - Additional fonts for better display

### Applications
- **Tilix** - Advanced terminal emulator
- **Google Chrome** - Web browser
- **1Password** - Password manager
- **Spotify** - Music streaming service
- **IntelliJ IDEA** - Integrated Development Environment

### Development Tools
- **Docker** - Containerization platform
- **Zed** - Modern code editor
- **Mise** - Universal version manager for multiple languages/tools

### Terminal & Shell
- **Zsh** - Advanced shell with autojump (set as default)
- **Starship** - Cross-shell prompt
- **Zap** - Plugin manager for Zsh

### System Integration
- **Flatpak** - Application packaging system
- **Desktop Applications** - Creates desktop entries for web services

## Directory Structure

```
setup-local-env/
├── install.sh              # Main installation script
├── scripts/                # Individual installation scripts
│   ├── 01-update-system.sh
│   ├── 02-install-essential.sh
│   ├── 03-install-fonts.sh
│   ├── 04-install-tilix.sh
│   ├── 05-install-chrome.sh
│   ├── 06-install-1password.sh
│   ├── 07-install-docker.sh
│   ├── 08-install-zsh.sh
│   ├── 09-install-mise.sh
│   ├── 10-install-starship.sh
│   ├── 11-install-zap.sh
│   ├── 12-install-zed.sh
│   ├── 13-install-spotify.sh
│   ├── 14-install-flatpak.sh
│   ├── 15-install-intellij.sh
│   └── 99-finalize.sh
└── apps/                   # Desktop application scripts
    ├── WhatsApp.sh         # WhatsApp web app desktop entry
    └── icons/              # Application icons directory
```

## Usage

After installation, you'll have:
- A modern terminal setup with Zsh and Starship prompt
- Essential development tools and languages managed by Mise
- Popular applications ready to use
- Desktop integration for web services

## Customization

You can modify individual scripts in the `scripts/` directory to:
- Add or remove packages
- Change installation parameters
- Modify configuration settings

## Post-Installation

The script automatically:
- Sets Zsh as the default shell
- Configures the terminal environment
- Creates desktop applications
- Performs system cleanup

## Troubleshooting

- Ensure you have root/sudo privileges
- Check internet connectivity for package downloads
- Review individual script logs if installation fails
- Some applications may require manual configuration after installation

## Contributing

Feel free to submit issues and enhancement requests. When adding new tools or applications, follow the existing script naming convention (XX-description.sh) and maintain the installation order.

## License

This project is open source. Please check the license file for details.
