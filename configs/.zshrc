# Personal config
# See - https://gist.github.com/LukeSmithxyz/e62f26e55ea8b0ed41a65912fbebbe52
PROMPT='%n@%m %~ %# '
export CDPATH=.:~/work
export PATH="$PATH:$HOME/nvim/bin"

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Include hidden files.

# vi mode
bindkey -v
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char
export KEYTIMEOUT=1
autoload edit-command-line; zle -N edit-command-line

# Custom history grep command
hgrep() {
    # Load history from the history file
    fc -R
    # Use fc -l to list history and grep it
    fc -ln 1 | grep --color=auto -i "$@"
}

# Env specific shell settings
if [[ -f "$HOME/.local/bin/env" ]]; then
  . "$HOME/.local/bin/env"
fi
