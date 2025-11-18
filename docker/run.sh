#!/usr/bin/env bash

docker_args=(
    -it
    --gpus all
    --user $(id -u):$(id -g)
)

if [ -d "$HOME/work" ]; then
    docker_args+=(-v "$HOME/work:/home/$(whoami)/work")
fi

if [ -d "$HOME/miniconda3" ]; then
    docker_args+=(-v "$HOME/miniconda3:/home/$(whoami)/miniconda3")
fi

docker run "${docker_args[@]}" dev
