## 🛠 Neovim Setup Script

This script sets up Neovim with my preferred configuration, inspired by ThePrimeagen's setup but customized for better usability with a QWERTY layout. It also helps you start tracking your own changes independently.
While the script hasn’t been tested on Linux, it should work fine as long as Neovim is installed.

### 🚀 Usage

```
chmod +x setup.sh
./setup.sh
```

### 📋 What It Does

- Installs or upgrades Neovim via Homebrew if needed
- Backs up your existing Neovim config
- Copies the current configuration to your Neovim directory. Check lua/config, lua/plugins, and .luarc.json in repo for more details.
- Initializes a Git repository inside `~/.config/nvim`
- **Adds a post-commit hook** that syncs changes back to this setup directory
- Optionally reinitializes Git in this directory so you can start fresh tracking and share your settings across machines

