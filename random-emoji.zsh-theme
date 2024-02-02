# zsh

EMOJI=(💩 🐦 🚀 🐞 🎨 🍕 🐭 👽 ☕️ 🔬 💀 🐷 🐼 🐶 🐸 🐧 🐳 🍔 🍣 🍻 🔮 💰 💎 💾 💜 🍪 🌞 🌍 🐌 🐓 🍄 )

function random_emoji {
  echo -n "$EMOJI[$RANDOM%$#EMOJI+1]"
}

function prompt_status() {
  echo -n "%(?.%f.%F{1})"  # if retcode == 0 ? reset : red
}

PROMPT="$(random_emoji) "
RPROMPT='%c'

# if you want to show git branch uncomment next lines
RPROMPT='%{$fg_bold[colour255]%}$(prompt_status)%c$(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX=" : "
ZSH_THEME_GIT_PROMPT_SUFFIX=""
