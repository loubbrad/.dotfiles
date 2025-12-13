#!/bin/bash
set -e 

DOTFILES_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
INSTALL_CONDA=false
INSTALL_SSH=false
SHELL_RESTART_REQUIRED=false

for arg in "$@"; do
  case $arg in
    --conda) INSTALL_CONDA=true
      shift
      ;;
    --ssh)
      INSTALL_SSH=true
      shift
      ;;
  esac
done


if [ "$(uname -m)" != "x86_64" ]; then
    echo "This script only supports the x86_64 architecture." >&2
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
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
}

install_neovim() {
    if command -v nvim >/dev/null 2>&1; then
        return
    fi
    
    SYSTEM_GLIBC=$(ldd --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
    REQUIRED_GLIBC="2.33"

    # Compare required versions
    if [ "$(printf '%s\n' "$REQUIRED_GLIBC" "$SYSTEM_GLIBC" | sort -V | head -n1)" = "$SYSTEM_GLIBC" ] && [ "$SYSTEM_GLIBC" != "$REQUIRED_GLIBC" ]; then
        echo "> System GLIBC ($SYSTEM_GLIBC) is older than required ($REQUIRED_GLIBC)."
        echo "> Installing fallback Neovim (static/older GLIBC support)..."
        NVIM_URL="https://github.com/neovim/neovim-releases/releases/download/v0.11.5/nvim-linux-x86_64.tar.gz"
    else
        echo "> Installing Neovim..."
        NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
    fi

    mkdir -p "$HOME/nvim"
    curl -LO "$NVIM_URL"
    tar -C "$HOME/nvim" -xzf nvim-linux-x86_64.tar.gz --strip-components=1
    rm nvim-linux-x86_64.tar.gz
}

install_miniconda() {
    if [ ! -d "$HOME/miniconda3" ] && ! command -v conda >/dev/null 2>&1; then
        echo "> Installing Miniconda..."
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
        bash miniconda.sh -b -p "$HOME/miniconda3"
        rm miniconda.sh
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

    echo " - Decrypting archive..."
    if gpg --decrypt "$encrypted_archive" 2>/dev/null | tar -xz -C "$temp_ssh_dir"; then
        
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
    else
        echo " - Error: Decryption failed. No changes were made to existing SSH keys." >&2
        rm -rf "$temp_ssh_dir"
        exit 1
    fi
}

main() {
    mkdir -p "$HOME/work"
    mkdir -p "$HOME/.cache/zsh"

    install_tools
    install_neovim

    if [ "$INSTALL_CONDA" = true ]; then
        install_miniconda
    fi

    link_configs

    if [ "$INSTALL_SSH" = true ]; then
        install_ssh
    fi

    if [ "$INSTALL_CONDA" = true ]; then
        echo "> Initializing conda..."
        "$HOME/miniconda3/bin/conda" init zsh
        "$HOME/miniconda3/bin/conda" init bash
        SHELL_RESTART_REQUIRED=true
    fi

    # Change default shell if not already zsh
    if [[ "$SHELL" != */zsh ]]; then
        echo "> Changing shell to zsh..."
        sudo chsh -s "$(which zsh)" "$USER"
        SHELL_RESTART_REQUIRED=true
    fi

    if [ "$SHELL_RESTART_REQUIRED" = true ]; then
        echo ""
        echo "#####################################################################"
        echo "IMPORTANT: A shell restart or new login session is required for all"
        echo "           changes (like zsh or conda) to take effect."
        echo "#####################################################################"
    fi
}

main
