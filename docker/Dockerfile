FROM nvidia/cuda:12.5.0-devel-ubuntu22.04

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

RUN git clone https://github.com/loubbrad/.dotfiles ~/.dotfiles
RUN bash ~/.dotfiles/init.sh --conda

CMD ["/usr/bin/zsh"]
