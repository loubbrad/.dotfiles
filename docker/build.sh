SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

docker build \
    --build-arg USERNAME=$(whoami) \
    --build-arg UID=$(id -u) \
    --build-arg DOTFILES_HASH=$(git ls-remote https://github.com/loubbrad/.dotfiles HEAD | cut -f1) \
    --build-arg GID=$(id -g) \
    -t dev $SCRIPT_DIR
