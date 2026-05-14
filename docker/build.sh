SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
docker_uid="${DOCKER_UID:-$(id -u)}"
docker_gid="${DOCKER_GID:-$(id -g)}"

(
    cd "$SCRIPT_DIR" || exit 1
    docker build \
        --build-arg UID="$docker_uid" \
        --build-arg DOTFILES_HASH=$(git ls-remote https://github.com/loubbrad/.dotfiles HEAD | cut -f1) \
        --build-arg GID="$docker_gid" \
        -t dev .
)
