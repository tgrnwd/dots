#!/usr/bin/env bash
# bootstrap-tools.sh
# Installs starship and mise if they are not already present.
# Auto-detects macOS vs Linux; prefers Homebrew on macOS when available.

_bootstrap_install_starship() {
  echo "bootstrap: installing starship..."
  if [[ "$OSTYPE" == darwin* ]] && command -v brew &> /dev/null; then
    brew install starship
  else
    # Official installer works on both Linux and macOS; --yes skips confirmation
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
  fi
}

_bootstrap_install_mise() {
  echo "bootstrap: installing mise..."
  if [[ "$OSTYPE" == darwin* ]] && command -v brew &> /dev/null; then
    brew install mise
  else
    # Official installer; places mise at ~/.local/bin/mise
    curl https://mise.run | sh
  fi
}

_bootstrap_install_mise_completions_sync() {
  command -v mise-completions-sync &> /dev/null && return

  echo "bootstrap: installing mise-completions-sync..."
  if command -v mise &> /dev/null; then
    mise use -g github:alltuner/mise-completions-sync
  elif [[ "$OSTYPE" == darwin* ]] && command -v brew &> /dev/null; then
    brew install alltuner/tap/mise-completions-sync
  elif command -v cargo &> /dev/null; then
    cargo install mise-completions-sync
  else
    echo "bootstrap: unable to install mise-completions-sync; install mise first" >&2
    return 1
  fi
}

_bootstrap_configure_mise_completions_hook() {
  local config hook

  command -v mise &> /dev/null || return

  config="${MISE_GLOBAL_CONFIG_FILE:-$HOME/.config/mise/config.toml}"
  mkdir -p "$(dirname "$config")"
  [[ -f "$config" ]] || touch "$config"

  hook="$(mise config get -f "$config" hooks.postinstall 2> /dev/null || true)"
  if [[ "$hook" == *mise-completions-sync* ]]; then
    return
  fi

  if [[ -n "$hook" ]]; then
    echo "bootstrap: existing mise hooks.postinstall found; not overwriting"
    echo "bootstrap: add 'mise exec github:alltuner/mise-completions-sync -- mise-completions-sync --shell zsh' to it manually"
    return
  fi

  mise config set -f "$config" hooks.postinstall --type string "mise exec github:alltuner/mise-completions-sync -- mise-completions-sync --shell zsh"
}

_bootstrap_sync_mise_completions() {
  command -v mise &> /dev/null || return

  echo "bootstrap: syncing mise-managed tool completions..."
  if command -v mise-completions-sync &> /dev/null; then
    mise-completions-sync --shell zsh
  else
    mise exec github:alltuner/mise-completions-sync -- mise-completions-sync --shell zsh
  fi
}

_bootstrap_install_mise_tools() {
  local tools=(
    docker-cli
    jq
    kubectl
    lazygit
    ripgrep
    tree-sitter
    yq
  )
  echo "bootstrap: installing global mise tools..."
  mise use -g "${tools[@]/%/@latest}"
}

command -v gettext &> /dev/null || brew install gettext
command -v starship &> /dev/null || _bootstrap_install_starship
command -v mise &> /dev/null || _bootstrap_install_mise
_bootstrap_install_mise_tools
command -v mise-completions-sync &> /dev/null || _bootstrap_install_mise_completions_sync
_bootstrap_configure_mise_completions_hook
_bootstrap_sync_mise_completions

unset -f _bootstrap_install_starship \
  _bootstrap_install_mise \
  _bootstrap_install_mise_tools \
  _bootstrap_install_mise_completions_sync \
  _bootstrap_configure_mise_completions_hook \
  _bootstrap_sync_mise_completions
