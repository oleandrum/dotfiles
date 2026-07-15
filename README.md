# dotfiles

Personal macOS configuration, maintained as plain zsh files without shell
frameworks or plugins.

## What is managed

The repository links the selected files in `home/` and `config/` into the home
directory. Private identity, tokens, SSH keys, GnuPG key material, history and
generated caches are deliberately excluded.

## First use on a new Mac

1. Clone the repository to its final location, for example `~/Github/dotfiles`.
2. Run `./scripts/install` from the repository root.
3. Fill in `~/.gitconfig.local` from the generated template if Git signing or
   a personal identity is needed.
4. Install the declared tools with `brew bundle --file=Brewfile` after signing
   in to the App Store. See [the application notes](docs/applications.md).

`install` only creates local directories, writes no credentials, and delegates
link creation to `sync`; Homebrew and application installation stays an explicit
separate command.

## Routine commands

- `./scripts/backup` copies the selected current files into this repository.
- `./scripts/sync` creates missing symbolic links. It stops on collisions.
- `./scripts/sync --force` preserves colliding files in
  `~/.dotfiles-backups/<timestamp>/` before linking.
- `./scripts/backup-secrets` creates a passphrase-encrypted recovery archive on
  the Desktop. Move it to encrypted offline storage immediately; it is never
  added to Git.
- `./scripts/macos --dry-run` shows the selected macOS preference changes;
  `./scripts/macos --apply` applies them. It is deliberately separate from
  `install`. Safari and Mail settings are left to their own Settings interfaces,
  because modern macOS protects their preference containers.

## Shell commands

After `sync`, zsh provides a compact Flexoki-coloured prompt and these commands:

- `showdotfiles` and `hidedotfiles` change Finder's hidden-file visibility.
- `cleanup [directory]` deletes only Finder metadata (`.DS_Store`, `._*` and
  `.AppleDouble`) below a project directory. It refuses `$HOME` and `/`.
- `update` updates Homebrew, moves Node to the current LTS through NVM while
  carrying over global packages, and updates Deno. It deliberately leaves the
  system Ruby and Python installations to macOS.

All scripts accept `--dry-run`. Run `git diff` and `git status` after a backup,
then commit the changes you want to keep.

## Moving the repository

Symlinks use the repository's absolute path. If you move or rename the clone,
run `./scripts/sync --force` from its new location to refresh them.

## Credits

- Inspired in part by [Mathias Bynens’ dotfiles](https://github.com/mathiasbynens/dotfiles).
- Terminal colour palette: [Flexoki](https://stephango.com/flexoki).
- Runtime installation flows follow the official documentation for [Deno](https://deno.com/) and [NVM](https://github.com/nvm-sh/nvm).

## License

Unless a file states otherwise, the scripts and configuration files in this repository are licensed under the MIT License.

Copyright (c) 2026 @oleandrum

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
