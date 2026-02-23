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

1. [Install `brew`](https://brew.sh/)
2. [Install `oh-my-zsh`](https://ohmyz.sh/#install)
3. `brew install gh` and login
4. `brew install starship`
4. `brew install fnm`
`brew install bat`
5. `brew install tfswitch`
5. [Install Rancher Desktop](https://docs.rancherdesktop.io/getting-started/installation#installing-rancher-desktop-on-macos

#### Brew

##### Required

fnm - node
gh
starship
tfswitch

##### Optional

1password
1password-cli
caffeine
cursor
ghostty
powershell
ungoogled-chromium
g - go

azure-cli
bat
terraform-docs

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