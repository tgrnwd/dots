#!/bin/bash

while getopts "gnx" opt; do
  case $opt in
    g)
      GITCONFIG=true
      ;;
    n)
      NUGET=true
      ;;
    x)
      REMOVE_OLD=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

script_dir=$(dirname "$(readlink -f "$0")")

linkit () {
  [ -f "$HOME"/$1 ] && mv "$HOME"/$1 "$HOME"/.zzold$1
  ln -s "$script_dir"/$1 "$HOME"/$1
}

install_ohmyzsh_plugins() {
  echo "** installing oh-my-zsh plugins..."

  [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ] \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

  [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ] \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}

link_zsh() {
  echo "** linking zsh files..."

  linkit .zshrc
  linkit .exports.zsh
  linkit .aliases.zsh
  linkit .paths.zsh

  [ -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/random-emoji.zsh-theme ] && rm ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/random-emoji.zsh-theme
  ln -s "$script_dir"/random-emoji.zsh-theme  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/random-emoji.zsh-theme
 }

link_git() {
  echo "** linking git files..."

  linkit .gitignore
  cat "$script_dir"/.gitconfig > "$HOME"/.gitconfig

  name="$(gh api user | jq -r '.name')"

  [[ $(gh api user | jq -r '.email') != null ]] \
    && email="$(gh api user | jq -r '.email')" \
    || email="$(gh api user | jq -r '.id')+$(gh api user | jq -r '.login')@users.noreply.github.com"

  echo "** adding git config for $name <$email>"
  git config --global user.email "$email"
  git config --global user.name "$name"
}

link_configs() {
  echo "** linking .npmrc and .tfswitch.toml"

  linkit .npmrc
  linkit .tfswitch.toml
}

# Add GitHub Nuget Package Source; prompts for GitHub Org
ghnuget () {
  type dotnet > /dev/null 2>&1 && {
    ! [ -z $GITHUB_TOKEN ] && {
      echo -e "** .NET sdk found, GITHUB_TOKEN found. Adding GitHub Nuget Package Source..."

      echo -e "\nChoose an org to authenticate a GitHub Nuget Package source.\n"
      PS3="Enter a number: "
      select org in $(echo "$(gh org list)$(echo ' Skip')")
      do 
        
        break
      done

      [[ $org == "Skip" ]] && {
        echo "Skipping GitHub Nuget Package Source..."
      } || {
        if ! [[ $(dotnet nuget list source --format short | grep $org) ]]; then
            {
              echo "Adding GitHub Nuget Source for $org"
              dotnet nuget update source https://nuget.pkg.github.com/$org/index.json -n $org-github-nuget -u $(gh api user | jq -r '.login') -p $GITHUB_TOKEN --store-password-in-clear-text
            } || {
              echo "problem adding GitHub Nuget Source for $org"
            }
        else
            echo "GitHub Nuget Source already exists for $org; doing nothing."
        fi
      }
    } || {
      echo "GITHUB_TOKEN is not set. are you logged into gh?"
      echo "Skipping Adding GitHub Nuget Package Source..."
    }
  } || {
    echo "dotnet not installed"
    echo "Skipping Adding GitHub Nuget Package Source..."
  }
}



if [[ $# -eq 0 || ($# -eq 1 && $REMOVE_OLD == true ) ]]
  then
    link_zsh
    install_ohmyzsh_plugins
    link_git
    link_configs
    ghnuget
fi

if [[ $GITCONFIG == true ]]; then
  link_git
fi

[[ $NUGET == true ]] && ghnuget

if [[ $REMOVE_OLD == true ]]; then
  echo "-x option was passed, removing old dotfiles..."
  rm -rf "$HOME"/.zzold*
fi