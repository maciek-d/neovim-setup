#!/bin/bash

CLEAN_SETUP=false # Set to true to enable clean setup
NVIM_CONFIG_DIR="$HOME/.config/nvim"

backup_nvim_dirs() {
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

  rm -rf "$nvim_config_dir/.git"
  git init "$nvim_config_dir"
  git -C "$nvim_config_dir" add .
  git -C "$nvim_config_dir" commit -m "initial commit"
}

if [[ "$CLEAN_SETUP" == true ]]; then
  backup_nvim_dirs
fi

cp -r ./lua/config "$NVIM_CONFIG_DIR/lua/"
cp -r ./lua/plugins "$NVIM_CONFIG_DIR/lua/"
cp .luarc.json "$NVIM_CONFIG_DIR/.luarc.json"

setup_post_commit_hook() {
  local setup_dir hook_file

  setup_dir="$(cd "$(dirname "$0")" && pwd)"
  hook_file="$NVIM_CONFIG_DIR/.git/hooks/post-commit"

  cat > "$hook_file" <<EOF
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
