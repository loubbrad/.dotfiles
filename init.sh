#!/bin/bash
set -e 

SYSTEM_GLIBC=$(ldd --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
DOTFILES_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
export PATH="$HOME/.local/bin:$HOME/.fzf/bin:$PATH"
INSTALL_UV=false
INSTALL_SSH=false
SHELL_RESTART_REQUIRED=false
NO_ROOT=false

for arg in "$@"; do
  case $arg in
    --uv) INSTALL_UV=true
      shift
      ;;
    --ssh)
      INSTALL_SSH=true
      shift
      ;;
    --no-root)
      NO_ROOT=true
      shift
      ;;
  esac
done


if [ "$(uname -m)" != "x86_64" ]; then
    echo "This script only supports linux-x86_64." >&2
    exit 1
fi

if [ -z "${BASH_VERSION:-}" ]; then
    echo "This script must be run with bash." >&2
    exit 1
fi

if command -v apt >/dev/null 2>&1; then
    PKG_INSTALL="sudo apt update && sudo apt install -y"
elif command -v yum >/dev/null 2>&1; then
    PKG_INSTALL="sudo yum install -y"
else
    echo "Error: Could not find a supported package manager (apt, yum)." >&2
    exit 1
fi

install_tools() {
    echo "> Installing base tools: zsh, tmux, git, curl, wget, gnupg, fd, ag, ripgrep..."
    eval $PKG_INSTALL zsh tmux git curl wget gnupg fd-find silversearcher-ag ripgrep
}

glibc_at_least() {
    # returns 0 if system glibc >= required
    [ "$(printf '%s\n' "$1" "$SYSTEM_GLIBC" | sort -V | tail -n1)" = "$SYSTEM_GLIBC" ]
}

install_binaries() {
    if glibc_at_least 2.34; then
        NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
    elif glibc_at_least 2.17; then
        echo "> GLIBC $SYSTEM_GLIBC too old for latest neovim, using fallback"
        NVIM_URL="https://github.com/neovim/neovim-releases/releases/latest/download/nvim-linux-x86_64.tar.gz"
    else
        NVIM_URL=""
        echo "> GLIBC $SYSTEM_GLIBC too old for neovim binary install, skipping"
    fi

    if glibc_at_least 2.39; then
        TREE_SITTER_URL="https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz"
    elif glibc_at_least 2.34; then 
        TREE_SITTER_URL="https://github.com/tree-sitter/tree-sitter/releases/download/v0.25.10/tree-sitter-linux-x64.gz"
    else
        TREE_SITTER_URL=""
        echo "> GLIBC $SYSTEM_GLIBC too old for tree-sitter binary install, skipping"
    fi

    if [ -n "$NVIM_URL" ] && ! command -v nvim >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/nvim" ]; then
        echo "> Installing Neovim from $NVIM_URL..."
        mkdir -p "$HOME/nvim"
        curl -L "$NVIM_URL" -o nvim.tar.gz
        tar -C "$HOME/nvim" -xzf nvim.tar.gz --strip-components=1
        rm nvim.tar.gz
        ln -sf "$HOME/nvim/bin/nvim" "$HOME/.local/bin/nvim"
    fi

    if ! command -v fzf >/dev/null 2>&1 && [ ! -x "$HOME/.fzf/bin/fzf" ]; then
        echo "> Installing FZF..."
        [ -d "$HOME/.fzf/.git" ] || git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all --no-update-rc 
    fi

    if [ -n "$TREE_SITTER_URL" ] && ! command -v tree-sitter >/dev/null 2>&1; then
        echo "> Installing Tree-sitter from $TREE_SITTER_URL..."
        curl -L "$TREE_SITTER_URL" -o tree-sitter.gz
        gzip -d tree-sitter.gz
        chmod +x tree-sitter
        mv tree-sitter "$HOME/.local/bin/tree-sitter"
    fi

    echo "> Binary installation complete."
}

install_uv() {
    if ! command -v uv >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/uv" ]; then
        echo "> Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
}

link_configs() {
    echo "> Linking configuration files..."
    
    ln -sfn "$DOTFILES_DIR/configs/.gitconfig" "$HOME/.gitconfig"
    echo " - Linked .gitconfig"

    ln -sfn "$DOTFILES_DIR/configs/.zshrc" "$HOME/.zshrc"
    echo " - Linked .zshrc"

    ln -sfn "$DOTFILES_DIR/configs/.tmux.conf" "$HOME/.tmux.conf"
    echo " - Linked .tmux.conf"
    
    mkdir -p "$HOME/.config"
    ln -sfnT "$DOTFILES_DIR/configs/nvim" "$HOME/.config/nvim"
    echo " - Linked init.lua"

    mkdir -p "$HOME/.config/zsh"
    ln -sfn "$DOTFILES_DIR/configs/key-bindings.zsh" "$HOME/.config/zsh/key-bindings.zsh"
    echo " - Linked key-bindings.zsh"

    # Create machine-specific local config if it doesn't exist
    if [ ! -f "$HOME/.config/zsh/local.zsh" ]; then
        touch "$HOME/.config/zsh/local.zsh"
        echo " - Created local.zsh for machine-specific settings"
    fi
}

install_ssh() {
    echo "> Installing SSH configuration..."
    local encrypted_archive="$DOTFILES_DIR/ssh/ssh_archive.tar.gz.gpg"

    if [ ! -f "$encrypted_archive" ]; then
        echo "  - Error: Encrypted SSH archive not found at $encrypted_archive" >&2
        return 1
    fi

    local temp_ssh_dir
    temp_ssh_dir=$(mktemp -d)
    local temp_ssh_archive
    temp_ssh_archive=$(mktemp)

    echo " - Decrypting archive..."
    if gpg --decrypt "$encrypted_archive" > "$temp_ssh_archive" && tar -xzf "$temp_ssh_archive" -C "$temp_ssh_dir"; then
        
        if [ -d "$HOME/.ssh" ]; then
            echo " - Backing up existing .ssh to .ssh.bak..."
            rm -rf "$HOME/.ssh.bak" 
            mv "$HOME/.ssh" "$HOME/.ssh.bak"
        fi

        echo " - Installing new keys..."
        mv "$temp_ssh_dir" "$HOME/.ssh"

        echo "  - Setting secure file permissions..."
        chmod 700 "$HOME/.ssh"
        chown -R "$USER:$USER" "$HOME/.ssh"
        find "$HOME/.ssh" -type f ! -name "*.pub" -exec chmod 600 {} +
        find "$HOME/.ssh" -type f -name "*.pub" -exec chmod 644 {} +
        
        echo " - SSH keys installed successfully."
        rm -f "$temp_ssh_archive"
    else
        echo " - Error: Decryption failed. No changes were made to existing SSH keys." >&2
        rm -rf "$temp_ssh_dir"
        rm -f "$temp_ssh_archive"
        exit 1
    fi
}

main() {
    mkdir -p "$HOME/work"
    mkdir -p "$HOME/.cache/zsh"
    mkdir -p "$HOME/.local/bin"

    if [ "$NO_ROOT" = false ]; then
        install_tools
    fi
    install_binaries
    link_configs

    if [ "$INSTALL_UV" = true ]; then
        install_uv
    fi

    if [ "$INSTALL_SSH" = true ]; then
        install_ssh
    fi

    # Change default shell if not already zsh
    CURRENT_LOGIN_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
    if [ "$NO_ROOT" = false ] && [ "$CURRENT_LOGIN_SHELL" != "$(command -v zsh)" ]; then
        echo "> Changing shell to zsh..."
        sudo chsh -s "$(command -v zsh)" "$USER"
        SHELL_RESTART_REQUIRED=true
    fi

    if [ "$SHELL_RESTART_REQUIRED" = true ]; then
        echo ""
        echo "#####################################################################"
        echo "IMPORTANT: A shell restart or new login session is required for all"
        echo "           changes (like zsh) to take effect."
        echo "#####################################################################"
    fi
}

main
