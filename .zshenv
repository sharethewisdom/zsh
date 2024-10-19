# "${ZDOTDIR}/.zshenv"
skip_global_compinit=1

export HISTFILE=${XDG_DATA_HOME}/zsh/history
export HISTSIZE=10000000
export SAVEHIST=10000000
export ZLE_RPROMPT_INDENT=1
export ZBEEP='\e[?5h\e[?5l'
export WORDCHARS='*?_-./[]~=&;!#$%^(){}<>'
export HISTFILE=${XDG_DATA_HOME}/zsh/history
export MANWIDTH=999
export SSH_ASKPASS=/usr/bin/ksshaskpass
export BC_ENV_ARGS="$XDG_CONFIG_HOME/bc/bc.conf"

if (( $+commands[fzf] + $+commands[rg] )); then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git" "!~/Private"'
fi

unset VIM VIMRUNTIME
if (( $+commands[nvim] )) && [[ -z "$GIT_EDITOR" ]] ; then
  export GIT_EDITOR="nvim"
fi
# Remove Duplicates in $PATH and $LD_LIBRARY_PATH
typeset -U PATH
typeset -U LD_LIBRARY_PATH
