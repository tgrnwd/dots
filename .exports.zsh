DOTFILES_PATH=$HOME/dots

if type gh > /dev/null; then
  if [ -z $GITHUB_TOKEN ]; then
    export GITHUB_TOKEN=$(gh auth token)
  fi
fi


export STARSHIP_CONFIG=~/.starship.toml