# Applications

## Homebrew

Install the declared formulae and the App Store applications with:

```zsh
brew bundle --file=Brewfile
```

The `mas` entries require being signed in to the Mac App Store. They can fail
when an app has not yet been claimed by that Apple Account; in that case,
install it once from the App Store and rerun the command.

## Direct downloads

These applications are intentionally not installed by Homebrew. Download them
from their official sites after the base setup is complete:

- AppCleaner
- Firefox
- Little Snitch
- MacTeX
- Motrix
- Telegram
- The Unarchiver
- Ukelele
- Visual Studio Code
- WhatsApp
- Zoom

## Terminal

`config/terminal/Flexoki Light.terminal` is the exported Terminal profile.
Double-click it in Finder (or use Terminal's Settings import flow), then choose
**Flexoki Light** as the default profile.

## Fonts

Add redistributable font files to `fonts/`. The setup script installs them into
`~/Library/Fonts`; it does not use administrator privileges.

## Visual Studio Code

The repository manages the user settings, keybindings, Markdown snippets and a
portable extension list. `install` restores the extensions only when VS Code's
`code` command is available. To refresh the list:

```zsh
code --list-extensions --show-versions > config/vscode/extensions.txt
```
