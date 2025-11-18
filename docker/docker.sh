#!/usr/bin/env bash

docker_args=(
    -it
    --gpus all
)

if [ -d "$HOME/work" ]; then
    docker_args+=(-v "$HOME/work:/root/work")
fi

if [ -d "$HOME/miniconda3" ]; then
    docker_args+=(-v "$HOME/miniconda3:/root/miniconda3")
fi

docker run "${docker_args[@]}" dev
