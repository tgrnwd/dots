DOTFILES_PATH=$HOME/dots

if type gh > /dev/null; then
  if [ -z $GITHUB_TOKEN ]; then
    export GITHUB_TOKEN=$(gh auth token)
  fi
fi

#NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#GO
export GOPATH="$HOME/go"; export GOROOT="$HOME/.go"; export PATH="$GOPATH/bin:$PATH"; # g-install: do NOT edit, see https://github.com/stefanmaric/g
alias govm="$GOPATH/bin/g"; # g-install: do NOT edit, see https://github.com/stefanmaric/g
