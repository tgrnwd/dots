# Shortcuts
alias rasdf="omz reload"
alias c="clear"

# Shortcuts
alias ls="ls --color"
alias cc="code ."
alias ccc="cursor ."

# Download file and save it with filename of remote file
alias get="curl -O -L"

dotfilesinstall () {
    DOTFILES_PATH=$(dirname "$(readlink -f "$HOME/.zshrc")")
    $DOTFILES_PATH/install.sh "$@"
}

# Directories
alias dotfiles="cd $DOTFILES"
alias dev="cd $HOME/codes"

yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}

jq() {
  docker run -i --rm -v "$PWD:$PWD" -w "$PWD" ghcr.io/jqlang/jq:latest "$@"
}