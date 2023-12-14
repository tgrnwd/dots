#!/bin/bash

install_ohmyzsh_plugins() {
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}

link_zsh() {
  script_dir=$(dirname "$(readlink -f "$0")")
  mv "$HOME"/.zshrc "$HOME"/.zshrc.old
  ln -s "$script_dir"/.zshrc "$HOME"/.zshrc
  ln -s "$script_dir"/.aliases.zsh "$HOME"/.aliases.zsh
  ln -s "$script_dir"/random-emoji.zsh-theme   ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/random-emoji.zsh-theme
 }

link_git() {
  script_dir=$(dirname "$(readlink -f "$0")")
  ln -s "$script_dir"/.gitignore_global "$HOME"/.gitignore
  cat "$script_dir"/.gitconfig >> "$HOME"/.gitconfig
}

link_zsh
install_ohmyzsh_plugins
link_git
