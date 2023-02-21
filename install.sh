#!/usr/bin/env bash

apt_packages=""
apt_packages_ubuntu="zsh curl git tmux az gh docker"
apt_packages_github="tmux"


function check_env {
  true
}

function apt_install_packages {
    sudo apt-get update && sudo apt-get install -y "${apt_packages}"
}

function ubuntu_basic {
  sudo usermod -aG docker "$USER"

  # Use apt over HTTPS
  sudo apt update && sudo apt install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg \
      gnupg-agent \
      software-properties-common \
      zsh

  # Add AzureCLI to sources.list
  curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

  AZ_REPO=$(lsb_release -cs)
  echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
      sudo tee /etc/apt/sources.list.d/azure-cli.list

  # Add Docker to sources.list
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
}

function github_basic {
  true
}

function install_ohmyzsh {
  # Install Oh My Zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

function install_ohmyzsh_plugins {
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
}

function install_font {
  # Install JetBrains Mono typeface
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"
}

function link_dots {
  # Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
  rm "$HOME"/.zshrc
  ln -s "$HOME"/.dots/link/.zshrc "$HOME"/.zshrc

    # Link custom dotfiles
  ln -s "$HOME"/.dotfiles/.aliases.zsh "$HOME"/.aliases.zsh
  ln -s "$HOME"/.dotfiles/.gitignore_global "$HOME"/.gitignore
}

function install_nvm {
  # Install nvm
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
}

function install_tf_switch {
  ln -s "$HOME"/.dotfiles/.tfswitch.toml "$HOME"/.tfswitch.toml
  mkdir "$HOME"/bin
  echo PATH="$HOME"/bin:"$PATH"
  curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh >> tfswitch-install.sh && chmod +x tfswitch-install.sh
  ./tfswitch-install.sh -b "$HOME"/bin
}

function link_git {
  ln -s "$HOME"/.dots/link/.gitignore_global "$HOME"/.gitignore
  ln -s "$HOME"/.dots/link/.gitconfig "$HOME"/.gitconfig
}




if azure
- install_ohmyzsh
- install_tf_switch
- install gh cli binary

if ubuntu
- install_ohmyzsh
- ubuntu_basic
- install_tf_switch
- install_ubuntu_packages

if github
- install_tf_switch
- install_github_packages