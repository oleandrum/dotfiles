# Restoring GPG Keys from Backup

Instructions for extracting and importing GPG keys from an encrypted backup (`dotfiles-secrets-*.tar.gz.gpg`).

## 1. Extraction

The archive is GPG-encrypted and packed as `.tar.gz`. Decrypt and extract in one step, without leaving an intermediate file on disk:

```bash
gpg --decrypt dotfiles-secrets-YYYYMMDD-HHMMSS.tar.gz.gpg | tar -xzv
```

GPG will prompt for a passphrase (if symmetrically encrypted) or use an available private key from the keyring.

## 2. Backup Contents

The archive contains:

- `secret-keys.asc` — private key export (also contains the public part)
- `public-keys.asc` — public key export (redundant if you already have `secret-keys.asc`)
- `ownertrust.txt` — trust values for the keys

## 3. Importing

**Order matters** — import the keys first, then the ownertrust (it references a fingerprint that must already exist in the keyring):

```bash
gpg --import secret-keys.asc
gpg --import-ownertrust ownertrust.txt
```

`public-keys.asc` is not needed separately, since `secret-keys.asc` already includes the public part.

> If `gpg --import-ownertrust` hangs without a file passed as an argument, it's waiting for manual input from stdin — always pass the file path directly.

## 4. Verification

```bash
gpg --list-secret-keys
gpg --list-keys
```

Expected result: the key appears with `[ultimate]` trust level.

Encrypt/decrypt round-trip test:

```bash
echo "test" | gpg --encrypt --recipient <email> | gpg --decrypt
```

If it outputs `test` back — the key is working correctly.

---

# Restoring SSH Keys from Backup

Instructions for importing SSH keys from a backup (`ssh/` folder containing `config`, `id_ed25519`, `id_ed25519.pub`).

SSH doesn't require an import command — just copy the files into `~/.ssh/` with the correct permissions.

## 1. Copy into `~/.ssh/`

```bash
cp config id_ed25519 id_ed25519.pub ~/.ssh/
```

Check beforehand with `ls -la ~/.ssh/` to avoid overwriting active files with the same names.

## 2. Set Correct Permissions

SSH refuses to use keys with overly open permissions:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 600 ~/.ssh/config
```

## 3. Add the Key to ssh-agent (optional)

```bash
ssh-add ~/.ssh/id_ed25519
```

If the key is passphrase-protected, it will prompt for the passphrase (on macOS it may offer to save it in Keychain).

## 4. Verification

```bash
ssh-add -l
```

You should see the key's fingerprint listed.

Real connection test (e.g. GitHub):

```bash
ssh -T git@github.com
```

A successful response confirms the service recognizes the key.
