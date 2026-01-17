# VSCode Dotfiles Integration

VSCode provides native support for managing dotfiles across remote environments.

## Setup

### 1. Enable Dotfiles Sync

1. Open VSCode on your local machine
2. Navigate to **File > Preferences > Settings** (or `Ctrl + ,`)
3. Search for **"dotfiles"**
4. Set `Remote.SSH: Dotfiles Repository` to:
   ```
   https://github.com/tctibbs/dotfiles.git
   ```

### 2. Automatic Deployment

When you connect to a remote system via SSH, VSCode will:
1. Clone the dotfiles repository to the remote user's home directory
2. Execute the `setup.sh` script

### 3. settings.json Configuration

```json
{
    "dotfiles.repository": "https://github.com/tctibbs/dotfiles.git",
    "dotfiles.installCommand": "~/dotfiles/setup.sh"
}
```

## Multi-Layer SSH Connections

For environments with multiple SSH layers (e.g., local → remote server → Docker container):

### Layer 1: Local to Remote Server

1. Connect to the remote server
2. Configure dotfiles in the remote VSCode settings
3. Verify dotfiles are applied on the Linux server

### Layer 2: Remote Server to Docker Container

1. Connect to the Docker container from the remote server
2. Update settings.json inside the remote environment:

```json
{
    "remote.SSH.dotfiles.repository": "https://github.com/tctibbs/dotfiles.git",
    "remote.SSH.dotfiles.installCommand": "~/dotfiles/setup.sh"
}
```

3. Ensure the Docker container has git and internet access

### Notes

- Each layer must be configured individually
- Update dotfiles settings within each layer for consistency
- Ensure SSH keys or access tokens are configured for Git operations
