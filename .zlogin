if [[ -o interactive ]]; then
  eval "$(mise activate zsh)"
  
  # Tool completions (after compinit and mise PATH activation)
  type terraform &>/dev/null && complete -o nospace -C "$(command -v terraform)" terraform
  type docker &>/dev/null && source <(docker completion zsh)
else
  eval "$(mise activate zsh --shims)"
fi
