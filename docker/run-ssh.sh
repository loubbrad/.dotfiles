#!/usr/bin/env bash
set -euo pipefail

name="${NAME:-dev-ssh}"
port="${PORT:-2222}"
authorized_keys="${AUTHORIZED_KEYS:-$HOME/.ssh/authorized_keys}"

if [ ! -f "$authorized_keys" ]; then
    echo "Missing authorized_keys file: $authorized_keys" >&2
    exit 1
fi

authorized_keys_tmp="${XDG_RUNTIME_DIR:-/tmp}/docker-${name}-authorized_keys"
cp "$authorized_keys" "$authorized_keys_tmp"
chmod 644 "$authorized_keys_tmp"

docker_args=(
    -d
    --name "$name"
    --gpus all
    --user root
    -p "127.0.0.1:$port:22"
    -v "$authorized_keys_tmp:/tmp/authorized_keys:ro"
)

if [ -d "$HOME/work" ]; then
    docker_args+=(-v "$HOME/work:/home/ubuntu/work")
fi

docker run "${docker_args[@]}" dev /bin/bash -lc '
    set -euo pipefail
    install -d -m 700 -o ubuntu -g ubuntu /home/ubuntu/.ssh
    install -m 600 -o ubuntu -g ubuntu /tmp/authorized_keys /home/ubuntu/.ssh/authorized_keys
    exec /usr/sbin/sshd -D -e
'
