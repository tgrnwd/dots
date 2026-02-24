pathadd() {
    if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

pathadd $HOME/.local/bin
pathadd $HOME/.dotnet/tools
pathadd $HOME/.rd/bin # rancher desktop
pathadd $HOME/.git-ai/bin # git-ai

export GOROOT="$HOME/.go"
[ ! -d "$GOROOT" ] && mkdir -p "$GOROOT"