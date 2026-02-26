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

source "$script_dir/bootstrap-tools.sh" # Install starship and mise if missing

linkit() {
  [ -f "$HOME"/$1 ] && [ ! -L "$HOME"/$1 ] && mv "$HOME"/$1 "$HOME"/.zzold$1
  ln -sf "$script_dir"/$1 "$HOME"/$1
}

link_zsh() {
  echo "** sourcing zsh config..."

  local source_line="source \"$script_dir/.zshrc\""
  if ! grep -qF "$source_line" "$HOME/.zshrc" 2> /dev/null; then
    local tmp
    tmp=$(mktemp)
    {
      echo "$source_line"
      [[ -f "$HOME/.zshrc" ]] && cat "$HOME/.zshrc"
    } > "$tmp"
    mv "$tmp" "$HOME/.zshrc"
    echo "** added source line to ~/.zshrc"
  fi
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

if [[ $GITCONFIG != true ]]; then
  [[ -f "$HOME/.hushlogin" ]] || touch "$HOME/.hushlogin"
  link_zsh
  link_git
  linkit .npmrc
else
  link_git
fi

if [[ $REMOVE_OLD == true ]]; then
  echo "-x option was passed, removing old dotfiles..."
  rm -rf "$HOME"/.zzold*
fi
