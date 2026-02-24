# dots

Just some simple `Mac (Apple Silicon), GitHub Codespaces and WSL`-centric dotfiles to make life a little easier.

## Install

### For GitHub Codespaces

Enable the `Dotfiles` repo in [Codespace settings](https://github.com/settings/codespaces).

### For WSL (ubuntu) - out of date

1. [Install `Zsh`](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH#install-and-set-up-zsh-as-default)
    - `sudo apt install zsh`
    - `chsh -s $(which zsh)`
2. [Install `gh`](https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-raspberry-pi-os-apt) and login
3. Get a Docker
    - Rancher Desktop
    - or something else

### For Mac

Notes: `jq` already on system, Docker alias will override. 

1. [Install `brew`](https://brew.sh/)
2. `brew install gh` and login
3. `brew install starship`
7. [Install Rancher Desktop](https://docs.rancherdesktop.io/getting-started/installation#installing-rancher-desktop-on-macos)

#### Brew

##### Required
gh
starship

### Tools

- [`dotnet`](https://learn.microsoft.com/en-us/dotnet/core/install/)


Mac
---
caffeine
ghostty
powershell
ungoogled-chromium

work
---
1password
1password-cli
cursor
acli
azure-cli
aws
gloud

reg
---
bat
ddgr
gh
starship
claude-code


w/ mise
----
terraform
terraform-docs
uv
node
go


todo
---
replace rancher k3s/k3d