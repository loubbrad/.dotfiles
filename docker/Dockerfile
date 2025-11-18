FROM nvidia/cuda:12.5.0-devel-ubuntu22.04

RUN apt-get update && apt-get install -y \
    zsh tmux git curl wget xclip gnupg fzf fd-find silversearcher-ag sudo ffmpeg nvtop

RUN git clone https://github.com/loubbrad/.dotfiles ~/.dotfiles
# RUN bash ~/.dotfiles/init.sh --conda

CMD ["/usr/bin/bash"]
