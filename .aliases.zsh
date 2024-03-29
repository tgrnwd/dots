# Shortcuts
alias rasdf="omz reload"
alias c="clear"

# Shortcuts
alias ls="ls --color"
alias cc="code ."

# Download file and save it with filename of remote file
alias get="curl -O -L"

dotfilesinstall () {
    DOTFILES_PATH=$(dirname "$(readlink -f "$HOME/.zshrc")")
    $DOTFILES_PATH/install.sh "$@"
}

# Directories
alias dotfiles="cd $DOTFILES"
alias dev="cd $HOME/codes"

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
