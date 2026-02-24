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

command -v starship &> /dev/null || _bootstrap_install_starship
command -v mise &> /dev/null || _bootstrap_install_mise

unset -f _bootstrap_install_starship _bootstrap_install_mise
