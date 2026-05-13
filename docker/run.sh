#!/usr/bin/env bash

docker_args=(
    -it
    --gpus all
)

mount_volumes=false
for arg in "$@"; do
    if [[ "$arg" == "-m" || "$arg" == "--mount" ]]; then
        mount_volumes=true
        break
    fi
done

if [ "$mount_volumes" = true ]; then
    if [ -d "$HOME/work" ]; then
        docker_args+=(-v "$HOME/work:/home/ubuntu/work")
    fi

fi

docker run "${docker_args[@]}" dev
