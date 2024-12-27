# My Dotfiles

This repository contains my personal configuration files (dotfiles) to set up a consistent environment across multiple systems. 

## Contents

- **Fonts**: Personal fonts, including Nerd Fonts for powerline-compatible symbols.
- **Zsh Configuration**: Includes zsh plugins, theme, and aliases for a personalized shell experience.

## Installation

To get started with my dotfiles, clone this repository and run the setup script:

```bash
git clone https://github.com/username/dotfiles.git
cd dotfiles
./install.sh
```

## Configuring VSCode with Dotfiles

VSCode provides native support for managing dotfiles across remote environments. Follow these steps to set it up:

### 1. Enable Dotfiles Sync in VSCode

- Open VSCode on your local machine.
- Navigate to **File > Preferences > Settings** (or press `Ctrl + ,`).
- Search for **"dotfiles"**.
- Update the `Remote.SSH: Dotfiles Repository` setting with the Git link to your repository:

    ``` bash
    https://github.com/tctibbs/dotfiles.git
    ```

### 2. Apply Dotfiles Automatically on Remote Systems

- Whenever you connect to a remote system via SSH using VSCode, the repository will automatically clone into the remote user's home directory and execute its `install.sh` script.

### 3. Example Configuration in settings.json

Update your **settings.json** file with the following:

```json
{
    "dotfiles.repository": "https://github.com/tctibbs/dotfiles.git",
    "dotfiles.installCommand": "~/dotfiles/install.sh"
}
```

## Handling Multi-Layer SSH Connections

For environments involving multiple layers of SSH (e.g., connecting to a Docker container on a remote Linux server via a Windows PC), configure dotfiles in each layer:

### Layer 1: Local Machine to Remote Linux Server

1. After connecting to the remote server, repeat the above steps within the remote settings of VSCode.
2. Verify that the dotfiles are correctly applied on the Linux server.

### Layer 2: Remote Linux Server to Docker Container

1. After connecting to the remote server, follow the steps in the previous section to set up dotfiles for the Docker container.
2. Update the settings.json file inside the remote environment:

    ``` json
    {
    "remote.SSH.dotfiles.repository": "https://github.com/tctibbs/dotfiles.git",
    "remote.SSH.dotfiles.installCommand": "~/dotfiles/install.sh"
    }
    ```
3. Ensure the Docker container has access to git and the internet to clone the repository.

#### Notes for Multi-Layer Environments

- Each layer (local machine → remote server → container) must be configured individually.
- Update the dotfiles repository setting within each layer for consistent behavior.
- Ensure SSH keys or access tokens are correctly configured for Git operations across layers.
