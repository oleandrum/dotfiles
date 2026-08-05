# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

Personal macOS dotfiles for a single user (@oleandrum), maintained as plain zsh
scripts and config files — deliberately with no shell framework (no
Oh My Zsh / prezto / antidote) and no package manager for the scripts
themselves. There is no build step, no test suite, and no linter configured;
"development" here means editing the tracked config files and zsh scripts
directly, then dry-running the affected script.

## Repository layout

- `home/` — files that get symlinked to `$HOME` directly (`.zshrc`,
  `.zprofile`, `.gitconfig`, `.gitignore`, `.gitattributes`, `.editorconfig`,
  `.curlrc`, `.latexmkrc`, `.markdownlint`).
- `config/` — files that get symlinked to nested locations under `$HOME`
  (GnuPG, SSH, VS Code user settings, the Terminal profile).
- `templates/.gitconfig.local.example` — copied (not symlinked) to
  `~/.gitconfig.local` on first install; holds the user's real name, email
  and GPG signing key. Never commit an actual filled-in copy.
- `scripts/` — the zsh entry points described below.
- `fonts/` — redistributable font files installed to `~/Library/Fonts`.
- `docs/applications.md` — non-Homebrew app notes and VS Code extension
  refresh instructions.
- `Brewfile` — Homebrew formulae and Mac App Store (`mas`) apps; installed
  explicitly, never by `install`.

## The `home`/`config` ↔ `$HOME` mapping is the core mechanism

`scripts/sync` and `scripts/backup` both hardcode the same `entries` array
mapping a `$HOME`-relative path to a repository-relative path (e.g.
`'.zshrc::home/.zshrc'`, `'.ssh/config::config/ssh/config'`). **Any file
added to or removed from what's managed must update the `entries` array in
both scripts** — there is no single source of truth for this list beyond
keeping the two arrays identical. `install` calls `sync` after creating
`~/.ssh`, `~/.gnupg` and `~/.gitconfig.local`.

## Scripts (`scripts/`, all `#!/bin/zsh`)

- `install [--dry-run] [--force]` — macOS-only bootstrap. Creates
  `~/.ssh`/`~/.gnupg` (mode 700), seeds `~/.gitconfig.local` from the
  template, runs `sync`, installs Deno and NVM if missing, installs the
  current Node LTS, prints the Terminal-profile import path, copies fonts
  into `~/Library/Fonts`, and installs VS Code extensions from
  `config/vscode/extensions.txt` if the `code` CLI is available.
- `sync [--dry-run] [--force]` — creates the symlinks from the shared
  `entries` array. Without `--force` it aborts on any collision (existing
  non-matching file/symlink at the target) without changing anything.
  With `--force` it moves colliding files into
  `~/.dotfiles-backups/<timestamp>/` before linking. Skips entries where the
  target is already a symlink resolving to the same source. Re-running
  `sync --force` after moving the repo refreshes symlinks (they embed the
  repo's absolute path).
- `backup [--dry-run]` — the inverse of `sync`: copies each managed target
  from `$HOME` back into the repository (skipping ones already
  symlinked-in, since those have no independent content), then refreshes
  `config/vscode/extensions.txt` via `code --list-extensions
  --show-versions` (or by reading `~/.vscode/extensions` if the `code` CLI
  isn't available). Always inspect with `git diff` / `git status` after
  running it, and commit only what you intend to keep.
- `backup-secrets [--output DIRECTORY] [--dry-run]` — creates a
  passphrase-encrypted (`gpg --symmetric --cipher-algo AES256`) tarball of
  SSH identity files, GPG secret/public keys + ownertrust, and
  `~/.gitconfig.local`, written to `~/Desktop` by default. This material
  must never enter the Git history; move the archive to encrypted offline
  storage immediately after creation.
- `macos --dry-run | --apply` — applies a short, explicit list of `defaults
  write` preferences (Finder, Dock, Terminal encoding) plus a couple of
  `chflags`/`xattr` tweaks. Kept separate from `install` on purpose. Safari
  and Mail are deliberately left alone because modern macOS protects their
  preference containers.

All scripts follow the same conventions: `emulate -L zsh`, `setopt err_exit
no_unset pipe_fail` at the top, a `usage()` function, manual `case`-based
flag parsing (`--dry-run`, `--force`, `--help`/`-h`), and every mutating
script supports `--dry-run` that prints what it *would* do without touching
the filesystem. Preserve this pattern in any new or edited script — dry-run
output should stay accurate to the real path, and destructive/mutating
behavior should require an explicit flag (`--force`, `--apply`) rather than
being the default.

## What is intentionally excluded from version control

`.gitignore` excludes local identity and generated state: `.gitconfig.local`,
`*.local`, `*.secret`, `.env*`, shell history/completion caches, and all key
material (`config/ssh/id_*`, `config/ssh/known_hosts`, `config/ssh/cm-*`,
`config/gnupg/private-keys-v1.d/`, `pubring.kbx`, `trustdb.gpg`,
`openpgp-revocs.d/`, `config/gh/hosts.yml(.yaml)`). Only
`templates/.gitconfig.local.example` is explicitly re-included. When adding
new managed config, keep secrets and machine-specific identity out of the
tracked files the same way — add a template + gitignore entry rather than
committing real values.

## Shell environment specifics

- `.zprofile` sets up Homebrew's shellenv (checks both Apple Silicon
  `/opt/homebrew` and Intel `/usr/local` paths) before `.zshrc` loads.
- `.zshrc` builds `PATH` with `typeset -U path PATH` (dedup), conditionally
  loads Deno/NVM only if installed, and defines the interactive prompt
  (Flexoki palette, shows git branch + dirty state) and helper functions:
  `showdotfiles`/`hidedotfiles`, `copyssh`, `cleanup [dir]` (refuses to run
  against `$HOME` or `/`), and `update` (Homebrew + NVM Node LTS + Deno;
  explicitly leaves system Ruby/Python untouched).
- Git config (`home/.gitconfig`) assumes GPG commit/tag signing is
  configured via the included `~/.gitconfig.local`, uses `osxkeychain` for
  credentials, `rebase = true` on pull, and defines aliases like `trim`,
  `adda`, `cleanup`, `cleanup-preview`, `recommit` (amend --no-edit).

## Testing changes

There is no automated test suite. Verify changes by:
- Running the affected script with `--dry-run` first.
- For `sync`/`backup`, checking `git diff`/`git status` after a real run.
- Scripts are macOS-only and `err_exit`/`no_unset` guarded — a stray
  unset-variable reference or non-zero exit will abort the script
  immediately, which is intended behavior, not a bug to work around.
