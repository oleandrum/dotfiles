# Възстановяване на GPG ключове от бекъп

Инструкции за разархивиране и импортиране на GPG ключове от криптиран бекъп (`dotfiles-secrets-*.tar.gz.gpg`).

## 1. Разархивиране

Архивът е шифрован с GPG и опакован като `.tar.gz`. Декриптирай и разархивирай в едно, без да оставяш междинен файл на диска:

```bash
gpg --decrypt dotfiles-secrets-YYYYMMDD-HHMMSS.tar.gz.gpg | tar -xzv
```

GPG ще поиска парола (при симетрично шифроване) или ще използва наличен private key от keyring-а.

## 2. Съдържание на бекъпа

Архивът съдържа:

- `secret-keys.asc` — private key export (съдържа и public частта)
- `public-keys.asc` — public key export (излишен, ако вече имаш `secret-keys.asc`)
- `ownertrust.txt` — trust стойности за ключовете

## 3. Импортиране

**Важен е редът** — първо ключовете, после ownertrust (реферира към fingerprint, който трябва вече да съществува в keyring-а):

```bash
gpg --import secret-keys.asc
gpg --import-ownertrust ownertrust.txt
```

`public-keys.asc` не е нужен отделно, тъй като `secret-keys.asc` вече съдържа и публичната част.

> Ако `gpg --import-ownertrust` увисне без файл подаден като аргумент, той чака ръчен вход от stdin — винаги подавай пътя до файла директно.

## 4. Проверка

```bash
gpg --list-secret-keys
gpg --list-keys
```

Очакван резултат: ключът се появява с `[ultimate]` trust ниво.

Тест за encrypt/decrypt цикъл:

```bash
echo "test" | gpg --encrypt --recipient <email> | gpg --decrypt
```

Ако изведе `test` обратно — ключът работи коректно.
