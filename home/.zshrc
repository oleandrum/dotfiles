# Keep paths unique and make local executables available first.
typeset -U path PATH
path=("$HOME/bin" "$HOME/.local/bin" /usr/local/bin $path)

# MacTeX exposes its current TeX distribution through this stable path.
[[ -d /Library/TeX/texbin ]] && path=(/Library/TeX/texbin $path)
export PATH

# GPG needs the active terminal for pinentry.
if [[ -o interactive && -t 1 ]]; then
  export GPG_TTY="$(tty)"
fi

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=5000
SAVEHIST=10000
setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_save_no_dups
setopt share_history

# Deno is optional during a clean installation.
[[ -f "$HOME/.deno/env" ]] && source "$HOME/.deno/env"

# NVM is intentionally retained, but only loaded when installed.
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
fi
