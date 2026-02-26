# ── Plugin bootstrap ────────────────────────────────────────────────────────
export ZSH_PLUGIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
# Resolve the directory containing this .zshrc, following symlinks
export DOTFILES_PATH="$(dirname "$(realpath "${(%):-%x}")")"

_ensure_cloned() {
  [[ -d "$ZSH_PLUGIN_DIR/$2" ]] || git clone --depth=1 "https://github.com/$1.git" "$ZSH_PLUGIN_DIR/$2"
}

_ensure_cloned zsh-users/zsh-autosuggestions    zsh-autosuggestions
_ensure_cloned zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting
_ensure_cloned zsh-users/zsh-completions        zsh-completions
unfunction _ensure_cloned

# homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── Completion system ───────────────────────────────────────────────────────
# Add plugin completions and brew completions to fpath BEFORE compinit
fpath=("$ZSH_PLUGIN_DIR/zsh-completions/src" $fpath)
if type brew &>/dev/null; then
  fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi

autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit -d "${ZDOTDIR:-$HOME}/.zcompdump"
else
  compinit -C -d "${ZDOTDIR:-$HOME}/.zcompdump"
fi
autoload -U +X bashcompinit && bashcompinit

# Tool completions (after compinit)
type terraform &>/dev/null && complete -o nospace -C "$(which terraform)" terraform
type fnm &>/dev/null && eval "$(fnm completions --shell zsh)"

# ── Plugins ─────────────────────────────────────────────────────────────────
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ── History ─────────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_IGNORE_SPACE

# ── Convenience (replaces OMZ features) ─────────────────────────────────────
# take: mkdir + cd in one command
take() { mkdir -p "$1" && cd "$1" }

# bat alias (replaces zsh-bat plugin)
type bat &>/dev/null && alias cat='bat --paging=never'

# ── Starship prompt ─────────────────────────────────────────────────────────
export STARSHIP_CONFIG="$DOTFILES_PATH/.starship.toml"
eval "$(starship init zsh)"

# ── Mise package manager ────────────────────────────────────────────────────
eval "$(mise activate zsh)"

# ── Source config files ─────────────────────────────────────────────────────
source $DOTFILES_PATH/.aliases.zsh
source $DOTFILES_PATH/.paths.zsh