alias c="clear"
alias ls="ls --color"
alias grep='grep --color=auto'
alias get="curl -O -L" # Download file and save it with filename of remote file
alias dotfiles="cd $DOTFILES"
alias dev="cd $HOME/codes"

dotfilesinstall () {
    $DOTFILES_PATH/install.sh "$@"
}

gh() {
  command gh "$@"
  local exit_code=$?
  if [[ $exit_code -eq 0 && "$1" == "auth" && "$2" == "switch" ]]; then
    local user_json name gh_email email
    user_json="$(command gh api user)"
    name="$(echo "$user_json" | jq -r '.name')"
    gh_email="$(echo "$user_json" | jq -r '.email')"
    if [[ "$gh_email" != "null" && -n "$gh_email" ]]; then
      email="$gh_email"
    else
      local id login
      id="$(echo "$user_json" | jq -r '.id')"
      login="$(echo "$user_json" | jq -r '.login')"
      email="${id}+${login}@users.noreply.github.com"
    fi
    echo "** updating git config for $name <$email>"
    git config --global user.email "$email"
    git config --global user.name "$name"
    command gh auth setup-git
  fi
  return $exit_code
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