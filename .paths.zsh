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

# Colima Docker socket (macOS only)
if [[ "$(uname)" == "Darwin" ]] && command -v colima &>/dev/null; then
    _colima_json="$(colima status --json 2>/dev/null)"
    if [[ $? -eq 0 ]] && _docker_sock="$(echo "$_colima_json" | sed -n 's/.*"docker_socket"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"; then
        export DOCKER_HOST="$_docker_sock"
    fi
    unset _colima_json _docker_sock
fi

