#!/bin/bash

script_dir=$(dirname "$(readlink -f "$0")")

linkit () {
  [ -f "$HOME"/$1 ] && mv "$HOME"/$1 "$HOME"/.old$1
  ln -s "$script_dir"/$1 "$HOME"/$1
}

install_ohmyzsh_plugins() {
  [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ] \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

  [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ] \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}

link_zsh() {
  linkit .zshrc
  linkit .aliases.zsh
  linkit .paths.zsh
  linkit .exports.zsh

  [ -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/random-emoji.zsh-theme ] && rm ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/random-emoji.zsh-theme
  ln -s "$script_dir"/random-emoji.zsh-theme  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/random-emoji.zsh-theme
 }

link_git() {
  
  linkit .gitignore
  cat "$script_dir"/.gitconfig >> "$HOME"/.gitconfig
}

link_configs() {
  linkit .npmrc
  linkit .tfswitch.toml
}

# Add GitHub Nuget Package Source; prompts for GitHub Org
ghnuget () {
  type dotnet > /dev/null 2>&1 && {
    ! [ -z $GITHUB_TOKEN ] && {
      echo -e ".NET sdk found, GITHUB_TOKEN found. Adding GitHub Nuget Package Source..."

      echo "Add a GitHub Nuget Package source for...?"
      PS3="Enter a number: "
      select org in $(echo "$(gh org list)$(echo ' Skip')")
      do 
        echo $REPLY $org
        break
      done

      [[ $org == "Skip" ]] && {
        echo "Skipping GitHub Nuget Package Source..."
      } || {
        if ! [[ $(dotnet nuget list source --format short | grep $org) ]]; then
            {
              dotnet nuget update source https://nuget.pkg.github.com/$org/index.json -n $org-github-nuget -u $(gh api user | jq -r '.login') -p $GITHUB_TOKEN --store-password-in-clear-text
            } || {
              echo "problem adding GitHub Nuget Source"
            }
        else
            echo "GitHub Nuget Source already exists; doing nothing."
        fi
      }
    } || {
      echo "GITHUB_TOKEN is not set. are you logged into gh?"
    }
  } || {
    echo "dotnet not installed"
  }
}

link_zsh
install_ohmyzsh_plugins
link_git
link_configs
ghnuget