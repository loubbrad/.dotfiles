# Adapted from https://gist.github.com/LukeSmithxyz/e62f26e55ea8b0ed41a65912fbebbe52

if [[ "$TERM" == "xterm-ghostty" ]]; then
    export TERM="xterm-256color"
fi

PROMPT='%n@%m %~ %# '
export CDPATH=.:~/work
export PATH="$HOME/.local/bin:$PATH"

# History in cache directory
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS

# Editor
export EDITOR=nvim
export VISUAL=nvim

# FZF
export FZF_DEFAULT_COMMAND='ag -g ""'
export FZF_CTRL_T_COMMAND='fdfind'
source "$HOME/.config/zsh/key-bindings.zsh"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Basic auto/tab complete
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Include hidden files.

# vi mode
bindkey -v
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char
bindkey '^k' up-line-or-history
bindkey '^j' down-line-or-history
export KEYTIMEOUT=1
autoload edit-command-line
zle -N edit-command-line
bindkey -M viins '^E' edit-command-line
bindkey -M vicmd '^E' edit-command-line

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Machine-specific shell settings
if [[ -f "$HOME/.config/zsh/local.zsh" ]]; then
  source "$HOME/.config/zsh/local.zsh"
fi

