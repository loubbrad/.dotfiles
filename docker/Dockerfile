FROM nvidia/cuda:12.5.0-devel-ubuntu22.04

RUN apt-get update && apt-get install -y \
    zsh tmux git curl wget xclip gnupg fzf fd-find silversearcher-ag sudo ffmpeg nvtop ffmpeg

ARG USERNAME=louis
ARG USER_UID=1023
ARG USER_GID=1023
RUN groupadd --gid $USER_GID $USERNAME \
 && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
 && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


USER $USERNAME
WORKDIR /home/$USERNAME

RUN git clone https://github.com/loubbrad/.dotfiles ~/.dotfiles
# RUN bash ~/.dotfiles/init.sh --conda

CMD ["/usr/bin/bash"]
