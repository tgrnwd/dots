pathadd() {
    if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

pathadd $HOME/.local/bin
pathadd $HOME/.dotnet/tools
pathadd $HOME/.git-ai/bin # git-ai

# Colima Docker socket (macOS only)
[[ "$(uname)" == "Darwin" && -S "${HOME}/.colima/default/docker.sock" ]] &&
    export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
