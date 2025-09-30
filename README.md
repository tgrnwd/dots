# dots

Just some simple `GitHub Codespaces and WSL`-centric dotfiles to make life a little easier.

## Install

### For GitHub Codespaces

Enable the `Dotfiles` repo in [Codespace settings](https://github.com/settings/codespaces).

The default codespace comes with `Zsh` and `oh-my-zsh`, as well as `gh` (authenticated with a user token).

### For WSL (ubuntu)

1. [Install `Zsh`](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH#install-and-set-up-zsh-as-default)
    - `sudo apt install zsh`
    - `chsh -s $(which zsh)`
2. [Install `oh-my-zsh`](https://ohmyz.sh/#install)
3. [Install `gh`](https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-raspberry-pi-os-apt) and login
4. Get a Docker
    - Rancher Desktop
    - or something else

### For Mac

Notes: `jq` already on system, Docker alias will override. 

1. [Install `oh-my-zsh`](https://ohmyz.sh/#install)
2. [Install `gh`](`brew install gh`) and login
3. Get a Docker
    - Rancher Desktop
    - or something else

### Tools

- [`az`](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#option-1-install-with-one-command)
- [`aws`](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [`tfswitch`](https://tfswitch.warrensbox.com/Troubleshoot/)
    - in WSL, installing locally is preferred
    - e.g. `./install.sh -b $HOME/.local/bin`
- [`uv`](https://docs.astral.sh/uv/#installation)
- [`g`](https://github.com/stefanmaric/g)
- [`nvm`](https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating)
- [`sdkman`](https://sdkman.io/)
- [`dotnet`](https://learn.microsoft.com/en-us/dotnet/core/install/)