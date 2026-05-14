SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

(
    cd "$SCRIPT_DIR" || exit 1
    docker build \
        --build-arg UID="$(id -u)" \
        --build-arg DOTFILES_HASH=$(git ls-remote https://github.com/loubbrad/.dotfiles HEAD | cut -f1) \
        --build-arg GID="$(id -g)" \
        -t dev .
)
