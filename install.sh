#!/bin/bash

# install_ohmyzsh_plugins() {
#   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
#   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# }

# install_font() {
#   # Install JetBrains Mono typeface
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"
# }

# link_zsh() {
#   script_dir=$(dirname "$(readlink -f "$0")")
#   mv "$HOME"/.zshrc "$HOME"/.zshrc.old
#   ln -s "$script_dir"/.zshrc "$HOME"/.zshrc
#   ln -s "$script_dir"/.aliases.zsh "$HOME"/.aliases.zsh
#  }

# link_git() {
#   script_dir=$(dirname "$(readlink -f "$0")")
#   ln -s "$script_dir"/.gitignore_global "$HOME"/.gitignore
#   ln -s "$script_dir"/.gitconfig "$HOME"/.gitconfig
# }

# link_zsh
# install_font
# install_ohmyzsh_plugins
# link_git



create_symlinks() {
    # Get the directory in which this script lives.
    script_dir=$(dirname "$(readlink -f "$0")")

    # Get a list of all files in this directory that start with a dot.
    files=$(find -maxdepth 1 -type f -name ".*")

    # Create a symbolic link to each file in the home directory.
    for file in $files; do
        name=$(basename $file)
        echo "Creating symlink to $name in home directory."
        mv ~/$name ~/old.$name
        ln -s $script_dir/$name ~/$name
    done
}

create_symlinks