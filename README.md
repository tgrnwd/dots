# dots

## Install
----------

### For WSL

#### 1. Enable WSL2

Run in PowerShell, as admin (elevated):

```ps1
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
wsl --set-default-version 2
```

#### 2. Install dependencies

```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
| sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
sudo apt update && \
sudo apt install gh -y
```

Login to GH cli, add an SSH key
```
gh auth login
```

Clone this repo
```
gh repo clone tgrnwd/wsl-dots ~/.dotfiles && cd ~/.dotfiles
```

#### Post setup

```
az login
```

### For GitHub Codespaces

### For Azure Cloud Shell