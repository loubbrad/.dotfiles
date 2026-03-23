#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
IMAGE="$SCRIPT_DIR/devenv.simg"

apptainer shell --cleanenv --shell /usr/bin/zsh --nv "$IMAGE"
