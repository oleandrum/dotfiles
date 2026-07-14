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

All scripts accept `--dry-run`. Run `git diff` and `git status` after a backup,
then commit the changes you want to keep.

## Moving the repository

Symlinks use the repository's absolute path. If you move or rename the clone,
run `./scripts/sync --force` from its new location to refresh them.
