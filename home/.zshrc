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

# Minimal Flexoki prompt: user at host in directory, with optional Git state.
dotfiles_git_prompt() {
  local branch state
  branch="$(command git symbolic-ref --quiet --short HEAD 2>/dev/null || command git describe --tags --always 2>/dev/null)" || return

  if [[ -n "$(command git status --porcelain=v1 2>/dev/null)" ]]; then
    state='%F{#AF3029}*%f'
  else
    state='%F{#66800B}✓%f'
  fi

  print -Pn " %F{#205EA6}git:%f%F{#4385BE}${branch}%f ${state}"
}

setopt prompt_subst
PROMPT='%F{#24837B}%n%f %F{#6F6E69}at%f %F{#24837B}%m%f %F{#6F6E69}in%f %F{#5E409D}%1~%f$(dotfiles_git_prompt) %# '

# Finder visibility helpers. They affect only Finder's hidden-file preference.
showdotfiles() {
  defaults write com.apple.finder AppleShowAllFiles -bool true
  killall Finder
}

hidedotfiles() {
  defaults write com.apple.finder AppleShowAllFiles -bool false
  killall Finder
}

copyssh() {
  local public_key="$HOME/.ssh/id_ed25519.pub"
  [[ -f "$public_key" ]] || { print -u2 "Public key not found: $public_key"; return 1; }
  pbcopy < "$public_key"
  print 'Copied the SSH public key to the clipboard.'
}

# Remove Finder metadata from a project directory, never from $HOME or /.
cleanup() {
  local target="${1:-.}" resolved
  [[ -d "$target" ]] || { print -u2 "Not a directory: $target"; return 2; }
  resolved="${target:A}"
  if [[ "$resolved" == / || "$resolved" == "$HOME" ]]; then
    print -u2 "Refusing to clean $resolved; choose a project directory instead."
    return 2
  fi

  find "$resolved" -type f \( -name '.DS_Store' -o -name '._*' \) -print -delete
  find "$resolved" -depth -type d -name '.AppleDouble' -print -exec rm -rf {} +
}

# Update user-managed tools. System Ruby and Python are intentionally untouched.
update() {
  local current_node

  if (( $+commands[brew] )); then
    brew update && brew upgrade && brew cleanup
  else
    print -u2 'Homebrew is not installed; skipping it.'
  fi

  if (( $+functions[nvm] )); then
    current_node="$(nvm current 2>/dev/null)"
    if [[ "$current_node" == v* ]]; then
      nvm install --lts --reinstall-packages-from="$current_node" --latest-npm
      nvm alias default 'lts/*'
    else
      print -u2 'NVM has no active Node version; skipping Node update.'
    fi
  else
    print -u2 'NVM is not installed; skipping Node update.'
  fi

  if (( $+commands[deno] )); then
    deno upgrade
  else
    print -u2 'Deno is not installed; skipping it.'
  fi

  print 'System Ruby and Python are managed by macOS and were not changed.'
}
