#!/usr/bin/env bash
set -euo pipefail

name="${NAME:-louis-dev-ssh}"
port="${PORT:-2222}"
authorized_keys="${AUTHORIZED_KEYS:-$HOME/.ssh/authorized_keys}"

if [ ! -f "$authorized_keys" ]; then
    echo "Missing authorized_keys file: $authorized_keys" >&2
    exit 1
fi

docker_args=(
    -d
    --name "$name"
    --gpus all
    --user root
    -p "127.0.0.1:$port:22"
    -v "$authorized_keys:/home/ubuntu/.ssh/authorized_keys:ro"
)

if [ -n "${SHARED_GID:-}" ]; then
    docker_args+=(--group-add "$SHARED_GID")
fi

if [ -d "$HOME/work" ]; then
    docker_args+=(-v "$HOME/work:/home/ubuntu/work")
fi

docker run "${docker_args[@]}" louis-dev /usr/sbin/sshd -D -e
