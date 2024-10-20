# "${ZDOTDIR}/.zprofile"
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
  export PATH="$HOME/.local/bin:$PATH"
  # TODO: review if it is problematic to set the binary search path to be the same for different tools
  export PNPM_HOME="$HOME/.local/bin"
  export GOBIN="$HOME/.local/bin"
  export CARGO_HOME="$HOME/.local/bin"
  export NPM_CONFIG_PREFIX="$HOME/.local"
fi
export PROMPT_DIRTRIM=2
export DISPLAY=:1
export EDITOR=nvim

export LYNX_LSS="${XDG_CONFIG_HOME}/lynx/lynx.lss"
export LYNX_CFG="${XDG_CONFIG_HOME}/lynx/lynx.cfg"
export LESS='-F -g -i -M -R -S -w -X -z-4'
