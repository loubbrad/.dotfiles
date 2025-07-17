#!/bin/bash
set -e 

DOTFILES_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
INSTALL_CONDA=false

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
    exit 1
fi

install_tools() {
    echo "> Installing base tools: zsh, tmux, git, curl, wget..."
    eval $PKG_INSTALL zsh tmux git curl wget xclip

}

install_neovim() {
    if command -v nvim >/dev/null 2>&1; then
        return
    fi
    echo "> Installing Neovim..."
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    mkdir -p "$HOME/nvim"
    tar -C "$HOME/nvim" -xzf nvim-linux64.tar.gz --strip-components=1
    rm nvim-linux64.tar.gz
}

install_miniconda() {
    if [ ! -d "$HOME/miniconda3" ] && ! command -v conda >/dev/null 2>&1; then
        echo "› Installing Miniconda..."
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

main() {
    mkdir -p $HOME/work
    mkdir -p "$HOME/.cache/zsh"

    install_tools
    install_neovim
    
    if [ "$INSTALL_CONDA" = true ]; then
        install_miniconda
    fi

    link_configs

    if [ "$INSTALL_CONDA" = true ]; then
        echo "> Initializing conda..."
        "$HOME/miniconda3/bin/conda" init zsh
        "$HOME/miniconda3/bin/conda" init bash
    fi
    
    # Change default shell if not already zsh
    if [[ "$SHELL" != */zsh ]]; then
        echo "> Changing default shell to zsh"
        chsh -s "$(which zsh)"
    fi
}

main