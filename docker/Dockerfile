FROM nvidia/cuda:12.9.1-devel-ubuntu24.04

RUN apt-get update && apt-get install -y \
    zsh tmux git curl wget gnupg fd-find silversearcher-ag ripgrep sudo ffmpeg nvtop

ARG USERNAME=louis
ARG UID=1000
ARG GID=1000

RUN groupadd -g $GID $USERNAME \
    && useradd -m -u $UID -g $GID -s /usr/bin/zsh $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $USERNAME
WORKDIR /home/$USERNAME
ENV HOME=/home/$USERNAME
ENV USER=$USERNAME

ARG DOTFILES_HASH=latest
RUN git clone https://github.com/loubbrad/.dotfiles ~/.dotfiles
RUN bash ~/.dotfiles/init.sh --uv

CMD ["/usr/bin/zsh"]
