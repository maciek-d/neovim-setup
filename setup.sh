#!/bin/bash

NVIM_CONFIG_DIR="$HOME/.config/nvim"

check_neovim() {
    if command -v nvim &>/dev/null; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            if brew list --formula | grep -q '^neovim$' &&
                ! brew outdated --formula | grep -q '^neovim$'; then
                echo "Neovim is installed and up to date (via Homebrew)."
                return
            fi
        else # Neovim manually installed on linux
            echo "Neovim is installed. Version check skipped on non-macOS."
            return
        fi
    fi

    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo "Neovim is not installed."
        echo "Please install Neovim manually using your package manager (e.g. apt, pacman, dnf)."
        echo "Neovim is required for this script."
        echo "Make sure Neovim settings are located at $NVIM_CONFIG_DIR or update and rerun setup.sh"
        exit 1
    fi

    if ! command -v nvim &>/dev/null; then
        read -rp "Neovim is not installed. Install it now with homebrew? [y/N]: " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo "Neovim install skipped."
            echo "Neovim is required for this script."
            echo "Make sure neovim settings are located at $NVIM_CONFIG_DIR or update and rerun setup.sh"
            return
        fi

        printf 'Installing Neovim... Press Enter to continue...'
        read -r
        brew install --head utf8proc
        brew install neovim
    fi

    if brew outdated --formula | grep -q '^neovim$'; then
        read -rp "Neovim is outdated. Upgrade it? [y/N]: " confirm_upgrade
        [[ "$confirm_upgrade" == [yY] ]] && brew upgrade neovim
    fi

    if command -v brew &>/dev/null; then
        read -rp "Run 'brew doctor'? [y/N]: " confirm_doctor
        if [[ "$confirm_doctor" != "y" && "$confirm_doctor" != "Y" ]]; then
            echo "Skipped brew doctor."
            return
        fi

        brew doctor
    fi

    read -rp "Delete .git folder and reinitialize Git for your own tracking? [y/N]: " confirm_git_reset
    if [[ "$confirm_git_reset" == "y" || "$confirm_git_reset" == "Y" ]]; then
        rm -rf .git
        git init
        git add .
        git commit -m "initial commit"
        echo "Reinitialized Git for personal tracking."
    fi
}

check_neovim

install_dependencies() {
    if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &>/dev/null; then
        if ! command -v node &>/dev/null; then
            echo "Installing node (required by mason LSP servers)..."
            brew install node
        fi
        if ! command -v tree-sitter &>/dev/null; then
            echo "Installing tree-sitter CLI (required by nvim-treesitter to compile parsers)..."
            # NOTE: 'brew install tree-sitter' only installs the C library, not the CLI binary.
            # The CLI binary is installed via npm (downloads a prebuilt binary, no Rust needed).
            npm install -g tree-sitter-cli
        fi
    else
        if ! command -v tree-sitter &>/dev/null; then
            echo "Warning: 'tree-sitter' CLI not found. Install it via your package manager."
            echo "  macOS/Linux with node: npm install -g tree-sitter-cli"
            echo "  Linux with Rust: cargo install tree-sitter-cli"
        fi
        if ! command -v node &>/dev/null; then
            echo "Warning: 'node' not found. Install it via your package manager."
            echo "  macOS: brew install node"
            echo "  Linux: apt install nodejs npm / nvm install --lts"
        fi
    fi
}

install_dependencies

backup_nvim_dirs() {
    read -rp "Do a clean Neovim setup (will backup existing)? [y/N]: " confirm_clean
    [[ "$confirm_clean" != [yY] ]] && return

    dirs=(
        "$HOME/.config/nvim"
        "$HOME/.local/share/nvim"
        "$HOME/.local/state/nvim"
        "$HOME/.cache/nvim"
    )

    any_backup_exists=false
    for dir in "${dirs[@]}"; do
        if [[ -e "${dir}.bak" ]]; then
            any_backup_exists=true
            break
        fi
    done

    if $any_backup_exists; then
        echo "One or more backup folders already exist:"
        for dir in "${dirs[@]}"; do
            [[ -e "${dir}.bak" ]] && echo "  - ${dir}.bak"
        done
        read -rp "This will override all existing backups. Continue? [y/N]: " confirm
        [[ "$confirm" != "y" && "$confirm" != "Y" ]] && echo "Aborted." && return
        for dir in "${dirs[@]}"; do
            rm -rf "${dir}.bak"
        done
    fi

    for dir in "${dirs[@]}"; do
        if [[ -e "$dir" ]]; then
            mv "$dir" "${dir}.bak"
            echo "Moved $dir → ${dir}.bak"
        fi
    done

    mkdir -p "$NVIM_CONFIG_DIR"
    mkdir -p "$NVIM_CONFIG_DIR/lua"

    rm -rf "$NVIM_CONFIG_DIR/.git"
    git init "$NVIM_CONFIG_DIR"
    mkdir -p "$NVIM_CONFIG_DIR/.git/hooks"
}

backup_nvim_dirs

mkdir -p "$NVIM_CONFIG_DIR"
mkdir -p "$NVIM_CONFIG_DIR/lua"

cp ./init.lua "$NVIM_CONFIG_DIR/init.lua"
cp -r ./lua/config "$NVIM_CONFIG_DIR/lua/"
cp -r ./lua/plugins "$NVIM_CONFIG_DIR/lua/"
cp .luarc.json "$NVIM_CONFIG_DIR/.luarc.json"

if [[ ! -d "$NVIM_CONFIG_DIR/.git" ]]; then
    git init "$NVIM_CONFIG_DIR"
fi

mkdir -p "$NVIM_CONFIG_DIR/.git/hooks"

git -C "$NVIM_CONFIG_DIR" add .
git -C "$NVIM_CONFIG_DIR" commit -m "initial commit"

setup_post_commit_hook() {
    local setup_dir hook_file

    setup_dir="$(cd "$(dirname "$0")" && pwd)"
    hook_file="$NVIM_CONFIG_DIR/.git/hooks/post-commit"

    cat >"$hook_file" <<EOF
#!/bin/bash

SETUP_DIR="$setup_dir"
NVIM_DIR="\$HOME/.config/nvim"
COMMIT_MSG=\$(git -C "\$NVIM_DIR" log -1 --pretty=%B)

cp -r "\$NVIM_DIR/lua/plugins" "\$SETUP_DIR/lua/"
cp -r "\$NVIM_DIR/lua/config" "\$SETUP_DIR/lua/"
cp "\$NVIM_DIR/.luarc.json" "\$SETUP_DIR/.luarc.json"

git -C "\$SETUP_DIR" add .
git -C "\$SETUP_DIR" commit -m "\$COMMIT_MSG"
EOF

    chmod +x "$hook_file"
    echo "Created post-commit hook to sync config back to setup directory."
}

setup_post_commit_hook

echo "Setup complete. Open nvim to install plugins."
