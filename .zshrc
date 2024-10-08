# "${ZDOTDIR}/.zshrc"
# zmodload zsh/zprof
if [[ -n $WAYLAND_DISPLAY || -n $DISPLAY ]]; then
  dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY
fi

bindkey -v

# Gets the nth argument from the last command by pressing Alt+1, Alt+2 and Alt+3
bindkey -s '\e1' "!:0-0 \t"
bindkey -s '\e2' "!:1-1 \t"
bindkey -s '\e3' "!:2-2 \t"
# Gets the last argument
bindkey -s '\e4' "!:$ \t"

bindkey '_' insert-last-word

# Expand .. at the beginning, after space, or after any of ! " & ' / ; < > |
function _double-dot-expand() {
  if [[ ${LBUFFER} == (|*[[:space:]!\"\&\'/\;\<\>|]).. ]]; then
    LBUFFER+=/..
  else
    LBUFFER+=.
  fi
}
zle -N _double-dot-expand
bindkey . _double-dot-expand
bindkey -M isearch . self-insert

function _copy() {
  if [[ -z $BUFFER ]]; then
    setopt menu_complete localtraps
    zstyle -g catfilep ":completion:*:complete:cat:*" file-patterns
    zstyle -g catfiles ":completion:*:complete:cat:*" file-sort
    zstyle ":completion:*:complete:cat:*" file-patterns \
      "*(txt|md|py|sh|zsh|pl|log|vim):'recent text files'" \
      '*(-/):directories' '*:all-files'
          zstyle ":completion:*:complete:cat:*" file-sort time
          trap '
          zstyle ":completion:*:complete:cat:*" file-patterns ${(@)catfilep};
          zstyle ":completion:*:complete:cat:*" file-sort ${(@)catfiles}
          ' INT EXIT
          LBUFFER="cat "
          if (( $+commands[wl-copy] )); then
            RBUFFER="| wl-copy"
          elif (( $+commands[xclip] )); then
            RBUFFER="| xclip -selection clipboard"
          fi
          zle expand-or-complete-prefix
  fi
}
zle -N copy _copy
bindkey -M viins -- '\ec'  copy

function interruptible-expand-or-complete {
  COMPLETION_ACTIVE=1
  # automatically interrupt completion after a ten second timeout.
  ( sleep 10; kill -INT $$ ) &!
  zle expand-or-complete-prefix
  COMPLETION_ACTIVE=0
}

# Bind our completer widget to tab.
zle -N interruptible-expand-or-complete
bindkey '^I' interruptible-expand-or-complete

# Interrupt only if completion is active.
function TRAPINT {
  if [[ $COMPLETION_ACTIVE == 1 ]]; then
    COMPLETION_ACTIVE=0
    zle -M "Completion canceled."
    # Returning non-zero tells zsh to handle SIGINT,
    # which will interrupt the completion function.
    return 1
  else
    # Returning zero tells zsh that we handled SIGINT;
    # don't interrupt whatever is currently running.
    return 0
  fi
}

zstyle ':completion:*' use-cache  on
zstyle ':completion:*' completer _expand _complete  _ignored _correct _approximate _prefix
zstyle ':completion:*' accept-exact '*(N)'
# zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z} r:|[._-]=* l:|=*'
zstyle ':completion:*' verbose true
zstyle ':completion:*' file-list all
zstyle ':completion:*' file-sort date
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:-command-:*:' verbose false
zstyle ':completion:*:*:zcompile:*' ignored-patterns '(*~|*.zwc)'

zstyle ':completion:*:processes-names' command 'ps c -u ${USER} -o command | uniq'
    # complete manual by their section
zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true
zstyle ':completion:*:man:*'      menu yes select

zstyle ':completion:*:complete:(mpv|mplayer):*' tag-order '!urls'

source $ZDOTDIR/zsh-autosuggestions/zsh-autosuggestions.zsh
# source $ZDOTDIR/zsh-system-clipboard/zsh-system-clipboard.zsh
source $ZDOTDIR/zsh-no-ps2/zsh-no-ps2.plugin.zsh

# Git status on the right
ZSH_GIT_PROMPT_FORCE_BLANK=1
ZSH_GIT_PROMPT_SHOW_UPSTREAM="symbol"
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg_bold[default]%}≺ "
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_SEPARATOR=" "
ZSH_THEME_GIT_PROMPT_DETACHED="%{$fg_no_bold[cyan]%}:"
ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_no_bold[white]%}"
ZSH_THEME_GIT_PROMPT_UPSTREAM_SYMBOL="%{$fg_bold[yellow]%}⟳ "
ZSH_THEME_GIT_PROMPT_UPSTREAM_PREFIX="%{$fg[red]%}(%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_UPSTREAM_SUFFIX="%{$fg[red]%})"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg_no_bold[cyan]%}↓"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_no_bold[cyan]%}↑"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[red]%}✖"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[green]%}●"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg[red]%}✚"
ZSH_THEME_GIT_PROMPT_UNTRACKED="…"
ZSH_THEME_GIT_PROMPT_STASHED="%{$fg[blue]%}⚑"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✔"
source $ZDOTDIR/git-prompt.zsh
PROMPT='%F{yellow}%m%f %F{cyan}%(4~|%4>>%-2~%<<%(5~=%f%F{white}>%f%F{cyan}=%f%F{cyan}/)%2>/>%2d%<<%20>>%1d%<<|%F{cyan}%~%f)%f%(24l.
     . )%# '
# %F{blue}≻≻%f '
RPROMPT='$(gitprompt)'


bindkey -M viins '' backward-delete-char

setopt extended_glob glob_dots unset no_beep no_hup
# If globs do not match a file, just run the command rather than throwing a no-matches error.
# This is especially useful for some commands with '^', '~', '#', e.g. 'git show HEAD^1'
unsetopt nomatch

setopt hist_reduce_blanks hist_ignore_all_dups hist_ignore_space hist_reduce_blanks
export HISTSIZE=1000 SAVEHIST=1000
# ignore .. ../ ../.. ../../..
# ignore two character entries
# ignore entries with control characters
# ignore entries that contain certain commands
# ignore entries that contain the string 'http'
export HISTORY_IGNORE='([./]##|??|. *|*http*|ecryptfs*|nvim *|echo *|man *|info *|printf *|f *|cd *|mkdir *|mv *|rm*|grep *|exit)'

fpath=("$ZDOTDIR/functions" "$ZDOTDIR/complete" $fpath)

# taken from Fotios Lindiakos, Vincent Bernat
# https://gist.github.com/ctechols/ca1035271ad134841284?permalink_comment_id=4293215#gistcomment-4293215
() {
  setopt local_options
  setopt extendedglob
  local zcd=${1}
  local zcdc=${1}.zwc
  local zcomp_hours=${2:-24} # how often to regenerate the file
  local lock_timeout=${2:-1} # change this if compinit normally takes longer to run
  local lockfile=${zcd}.lock
  if [ -f ${lockfile} ]; then 
    if [[ -f ${lockfile}(#qN.mm+${lock_timeout}) ]]; then
      (
      echo "${lockfile} has been held by $(< ${lockfile}) for longer than ${lock_timeout} minute(s)."
      echo "This may indicate a problem with compinit"
      ) >&2 
    fi
    # Exit if there's a lockfile; another process is handling things
    return
  else
    # Create the lockfile with this shell's PID for debugging
    echo $$ > ${lockfile}
    # Ensure the lockfile is removed
    trap "rm -f ${lockfile}" EXIT
  fi
  autoload -Uz compinit
  # - '#q' is an explicit glob qualifier that makes globbing work within zsh's [[ ]] construct.
  # - 'N' makes the glob pattern evaluate to nothing when it doesn't match (rather than throw a globbing error)
  # - '.' matches "regular files"
  # - 'mh+${zcomp_hours}' matches files (or directories or whatever) that are older than ${zcomp_hours} hours.
  if [[ -n ${zcd}(#qN.mh+${zcomp_hours}) ]]; then
    # The file is old and needs to be regenerated
    compinit -i && autoload -Uz zrecompile && zrecompile -q $zcd
  else
    # The file is either new or does not exist. Either way, -C will handle it correctly
    compinit -C
  fi
} ${ZDOTDIR:-$HOME}/.zcompdump 

autoload -Uz history-beginning-search-menu
zle -N history-beginning-search-menu
bindkey '^X^X' history-beginning-search-menu
# sudo pacman -Syu zsh-syntax-highlighting
# sudo apt upgrade && sudo apt install zsh-syntax-highlighting
# /usr/local/share/zsh/zsh-history-substring-search.zsh could be sourced from /etc/zsh/zshrc
export HISTORY_SUBSTRING_SEARCH_PREFIXED=true
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# Use smart URL pasting and escaping.
autoload -Uz bracketed-paste-url-magic && zle -N bracketed-paste bracketed-paste-url-magic
autoload -Uz url-quote-magic && zle -N self-insert url-quote-magic

if (( $+commands[batcat] )); then
  alias bat='batcat'
  alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
  alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
  alias -g -- --help-all='--help-all 2>&1 | bat --language=help --style=plain'
fi

alias -g DN='&> /dev/null &'
alias -g L='|less'

if (( $+commands[ffmpeg] )); then
  alias record-desktop='ffmpeg -f pulse -i alsa_output.pci-0000_04_00.6.analog-stereo.monitor -c:a libmp3lame -q:a 6'
fi

# nvm -- sourcing is very slow, use lazy load
if [[ -f "$HOME/.nvm/nvm.sh" ]]; then
  function nvm() {
    unfunction nvm
    source "$HOME/.nvm/nvm.sh"
    nvm "$@"
  }
fi

if (( $+commands[htop] )); then
    alias top='htop'
    alias topc='htop -s PERCENT_CPU'
    alias topm='htop -s PERCENT_MEM'
fi

function ls (){
  command ls -l --group-directories-first --color=auto "$@"
}

cdpath() {
  local dir=$PWD
  # cd will also search all children of all of the dirs in the array `$cdpath`.
  cdpath=()
  # Add all ancestors of `$PWD` to `$cdpath`.
  while (( $#dir > 1 )); do
    # `:h` is the direct parent.
    dir=$dir:h
    cdpath+=( $dir )
  done
}

# Run the function above whenever we change directory.
add-zsh-hook chpwd cdpath

# function smart_cd (){
#   if [[ -f $1 ]] ; then
#     [[ ! -e ${1:h} ]] && return 1
#     print correcting ${1} to ${1:h}
#     builtin cd ${1:h}
#   else
#     builtin cd ${1}
#   fi
# }
#
# function cd (){
#   setopt localoptions
#   setopt extendedglob
#   local approx1 ; approx1=()
#   local approx2 ; approx2=()
#   if (( ${#*} == 0 )) || [[ ${1} = [+-]* ]] ; then
#     builtin cd "$@"
#   elif (( ${#*} == 1 )) ; then
#     approx1=( (#a1)${1}(N) )
#     approx2=( (#a2)${1}(N) )
#     if [[ -e ${1} ]] ; then
#       smart_cd ${1}
#     elif [[ ${#approx1} -eq 1 ]] ; then
#       print correcting ${1} to ${approx1[1]}
#       smart_cd ${approx1[1]}
#     elif [[ ${#approx2} -eq 1 ]] ; then
#       print correcting ${1} to ${approx2[1]}
#       smart_cd ${approx2[1]}
#     else
#       print couldn\'t correct ${1}
#     fi
#   elif (( ${#*} == 2 )) ; then
#     builtin cd $1 $2
#   else
#     print cd: too many arguments
#   fi
# }
#
alias g='git status'
alias gf='git fetch'
alias gd='git diff'
alias gc='git commit -a -m'
alias gca='git commit --amend --no-edit'

alias bc="bc -q"

alias nvim='nvim -p'
alias v='nvim -p'

alias chmod='nocorrect chmod --preserve-root -v'
alias chown='nocorrect chown --preserve-root -v'
alias grep='grep --color=auto --exclude-dir=\.git'
alias ..='cd ..'
alias ../..='cd ../..'
alias ../../..='cd ../../..'
alias mv='mv -i'
alias f='find . -maxdepth 10 -path "**/node_modules/*" -prune -o -type f -name'
alias x='tar -xvf'
alias zip="zip --exclude '*.git*' -r -FS"
alias tree="tree -I 'node_modules|bower_components'"
alias watch='watch --color -n1'

# pervent mpv and feh from accessing the network
(( $+commands[mpv] )) && alias mpv="unshare -r -n mpv"
(( $+commands[feh] )) && alias feh="unshare -r -n feh -F"
(( $+commands[scour] )) && alias scour='scour --set-precision=1'

() {
  local bin
  for bin in {pdflatex,latexmk,lualatex,xelatex,pslatex};do
    if (( $+commands[$bin] )); then
      alias $bin="max_print_line=10000 $bin"
    fi
  done
}

# zprof
