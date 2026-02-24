alias c="clear"
alias ls="ls --color"
alias get="curl -O -L" # Download file and save it with filename of remote file
alias dotfiles="cd $DOTFILES"
alias dev="cd $HOME/codes"

dotfilesinstall () {
    $DOTFILES_PATH/install.sh "$@"
}

ghtoken() {
  if type gh &>/dev/null; then
    export GITHUB_TOKEN=$(gh auth token)
    echo "GITHUB_TOKEN exported"
  else
    echo "gh CLI not found" >&2
    return 1
  fi
}

yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}

jq() {
  docker run -i --rm -v "$PWD:$PWD" -w "$PWD" ghcr.io/jqlang/jq:latest "$@"
}

update_zsh_plugins() {
  for d in "$ZSH_PLUGIN_DIR"/*/; do
    echo "Updating $(basename $d)..."
    git -C "$d" pull --ff-only
  done
}