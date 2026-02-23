pathadd() {
    if [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}
 
pathadd $HOME/.local/bin
pathadd $HOME/.dotnet/tools

# rancher desktop
export PATH="$HOME/.rd/bin:$PATH"

# node version manager: fnm
if type fnm > /dev/null; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# go version manager: g
export GOPATH="$HOME/go"; export GOROOT="$HOME/.go"; export PATH="$GOPATH/bin:$PATH"; # g-install: do NOT edit, see https://github.com/stefanmaric/g
alias govm="$GOPATH/bin/g"; # g-install: do NOT edit, see https://github.com/stefanmaric/g

# git-ai
if [[ -d "$HOME/.git-ai" ]]; then
  export PATH="$HOME/.git-ai/bin:$PATH"
fi
