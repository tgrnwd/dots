# Shortcuts
alias reloadshell="source $HOME/.zshrc"
alias c="clear"

# Shortcuts
alias ls="ls --color"
# alias -- +x="chmod +x"
# alias o="open"
# alias oo="open ."
# alias e="$EDITOR"
# alias cc="code ."

# Bat: https://github.com/sharkdp/bat
command -v bat >/dev/null 2>&1 && alias cat="bat --style=numbers,changes"

# Download file and save it with filename of remote file
alias get="curl -O -L"


# Directories
alias dotfiles="cd $DOTFILES"
alias dev="cd $HOME/Code"

# Git
alias gst="git status"
alias gb="git branch"
alias gc="git checkout"
alias gl="git log --oneline --decorate --color"
alias amend="git add . && git commit --amend --no-edit"
alias commit="git add . && git commit -m"
alias diff="git diff"
alias force="git push --force"
alias nah="git clean -df && git reset --hard"
alias pop="git stash pop"
alias pull="git pull"
alias push="git push"
alias resolve="git add . && git commit --no-edit"
alias stash="git stash -u"
alias unstage="git restore --staged ."
alias wip="commit wip"



cd() {
  builtin cd "$@";
  cdir=$PWD;
  if [ -e "$cdir/versions.tf" && command -v tfswitch]; then
    tfswitch
  fi
}

# Make a directory and cd to it
take() {
  mkdir -p $@ && cd ${@:$#}
}

yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}