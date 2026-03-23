#!/bin/bash
set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
IMAGE="$SCRIPT_DIR/devenv.simg"

APPTAINERENV_NSLOTS=${NSLOTS:-1} apptainer build "$IMAGE" "$SCRIPT_DIR/devenv.def"

echo "Built: $IMAGE"
