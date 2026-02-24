#!/bin/bash

while getopts "gnx" opt; do
  case $opt in
    g)
      GITCONFIG=true
      ;;
    x)
      REMOVE_OLD=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

script_dir=$(dirname "$(readlink -f "$0")")

linkit () {
  [ -f "$HOME"/$1 ] && mv "$HOME"/$1 "$HOME"/.zzold$1
  ln -sf "$script_dir"/$1 "$HOME"/$1
}

link_zsh() {
  echo "** linking zsh files..."

  linkit .zshrc
  linkit .hushlogin
  linkit .starship.toml
 }

link_git() {
  echo "** linking git files..."

  linkit .gitignore
  cat "$script_dir"/.gitconfig > "$HOME"/.gitconfig

  name="$(gh api user | jq -r '.name')"

  [[ $(gh api user | jq -r '.email') != null ]] \
    && email="$(gh api user | jq -r '.email')" \
    || email="$(gh api user | jq -r '.id')+$(gh api user | jq -r '.login')@users.noreply.github.com"

  echo "** adding git config for $name <$email>"
  git config --global user.email "$email"
  git config --global user.name "$name"
}

link_configs() {
  echo "** linking .npmrc and .tfswitch.toml"

  linkit .npmrc
}

if [[ $# -eq 0 || ($# -eq 1 && $REMOVE_OLD == true ) ]]
  then
    link_zsh
    link_git
    link_configs
fi

if [[ $GITCONFIG == true ]]; then
  link_git
fi

if [[ $REMOVE_OLD == true ]]; then
  echo "-x option was passed, removing old dotfiles..."
  rm -rf "$HOME"/.zzold*
fi