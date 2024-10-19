# simple Zsh configs

<picture>
 <source media="(prefers-color-scheme: dark)" srcset="zsh-dark.png">
 <source media="(prefers-color-scheme: light)" srcset="zsh-light.png">
 <img alt="zsh shell picture" src="zsh-light.png">
</picture>

## installation

```sh
echo 'export ZDOTDIR=${XDG_CONFIG_HOME}/zsh' > "$HOME/.zshenv"
source "$HOME/.zshenv"
cd $ZDOTDIR
git clone --recurse-submodules https://github.com/sharethewisdom/zsh.git
echo 'source $ZDOTDIR/.zshenv' >> "$HOME/.zshenv"
```

optionally, symlink the bash-compatible `.zprofile` to `~/.profile`

```sh
ln -s $ZDOTDIR/.zprofile ~/.profile
```
