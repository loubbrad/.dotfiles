#!/bin/bash
set -e 

DOTFILES_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
INSTALL_CONDA=false
INSTALL_SSH=false
SHELL_RESTART_REQUIRED=false

for arg in "$@"; do
  case $arg in
    --conda)
      INSTALL_CONDA=true
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

if [[ " $@ " =~ " --conda " ]]; then
    INSTALL_CONDA=true
fi

if command -v apt >/dev/null 2>&1; then
    PKG_INSTALL="sudo apt update && sudo apt install -y"
elif command -v yum >/dev/null 2>&1; then
    PKG_INSTALL="sudo yum install -y"
elif command -v pacman >/dev/null 2>&1; then
    PKG_INSTALL="sudo pacman -S --noconfirm"
else
    echo "Error: Could not find a supported package manager (apt, yum, pacman)." >&2
    exit 1
fi

install_tools() {
    echo "> Installing base tools: zsh, tmux, git, curl, wget, xclip gnupg..."
    eval $PKG_INSTALL zsh tmux git curl wget xclip gnupg, 
}

install_neovim() {
    if command -v nvim >/dev/null 2>&1; then
        return
    fi
    echo "> Installing Neovim..."
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    mkdir -p "$HOME/nvim"
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
    
    mkdir -p "$HOME/.config/nvim"
    ln -sfn "$DOTFILES_DIR/configs/init.vim" "$HOME/.config/nvim/init.vim"
    echo " - Linked init.vim"
}

install_ssh() {
    echo "> Installing SSH configuration..."
    local encrypted_archive="$DOTFILES_DIR/ssh/ssh_archive.tar.gz.gpg"

    if [ ! -f "$encrypted_archive" ]; then
        echo "  - Error: Encrypted SSH archive not found at $encrypted_archive" >&2
        return 1
    fi

    mkdir -p -m 700 "$HOME/.ssh"

    echo " - Decrypting archive (you will be prompted for the passphrase)..."
    if gpg --decrypt "$encrypted_archive" 2>/dev/null | tar -xz -C "$HOME/.ssh"; then
        echo "  - Setting secure file permissions..."
        chmod 700 "$HOME/.ssh"
        find "$HOME/.ssh" -type f ! -name "*.pub" ! -name "config" ! -name "known_hosts*" -exec chmod 600 {} +
        find "$HOME/.ssh" -type f \( -name "*.pub" -o -name "config" -o -name "known_hosts*" \) -exec chmod 644 {} +
        echo " - SSH keys installed successfully."
    else
        echo " - Error: Decryption or extraction failed. Was the passphrase correct?" >&2
        rm -rf "$HOME/.ssh"
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