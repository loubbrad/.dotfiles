FROM nvidia/cuda:12.9.1-devel-ubuntu24.04

RUN apt-get update && apt-get install -y \
    zsh tmux git curl wget gnupg fd-find silversearcher-ag ripgrep sudo ffmpeg nvtop python3.12-dev

ARG USERNAME=ubuntu
ARG UID=1000
ARG GID=1000

RUN groupmod -g "$GID" "$USERNAME" \
    && usermod -u "$UID" -g "$GID" "$USERNAME" \
    && chown -R "$UID:$GID" "/home/$USERNAME"

# SSH server for detached, local-only container access.
RUN apt-get update && apt-get install -y openssh-server \
    && mkdir -p /run/sshd "/home/$USERNAME/.ssh" /etc/ssh/sshd_config.d \
    && chmod 700 "/home/$USERNAME/.ssh" \
    && chown -R "$UID:$GID" "/home/$USERNAME/.ssh" \
    && printf '%s\n' \
        'PasswordAuthentication no' \
        'KbdInteractiveAuthentication no' \
        'PermitRootLogin no' \
        'PubkeyAuthentication yes' \
        "AllowUsers $USERNAME" \
        > /etc/ssh/sshd_config.d/dev-container.conf

RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $USERNAME
WORKDIR /home/$USERNAME
ENV HOME=/home/$USERNAME
ENV USER=$USERNAME

ARG DOTFILES_HASH=latest
RUN git clone https://github.com/loubbrad/.dotfiles ~/.dotfiles
RUN bash ~/.dotfiles/init.sh --uv

CMD ["/usr/bin/zsh"]
