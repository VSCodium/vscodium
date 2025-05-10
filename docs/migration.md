<!-- order: 20 -->

# Migration

## Table of Contents

- [Migrating from Visual Studio Code to Codex](#migrating)

## <a id="migrating"></a>Migrating from Visual Studio Code to Codex

Codex (and a freshly cloned copy of vscode built from source) stores its extension files in `~/.vscode-oss`. So if you currently have Visual Studio Code installed, your extensions won't automatically populate. You can reinstall your extensions from the Marketplace in Codex, or copy the `extensions` from `~/.vscode/extensions` to `~/.vscode-oss/extensions`.

Visual Studio Code stores its `keybindings.json` and `settings.json` file in these locations:

- __Windows__: `%APPDATA%\Code\User`
- __macOS__: `$HOME/Library/Application Support/Code/User`
- __Linux__: `$HOME/.config/Code/User`

You can copy these files to the Codex user settings folder:

- __Windows__: `%APPDATA%\Codex\User`
- __macOS__: `$HOME/Library/Application Support/Codex/User`
- __Linux__: `$HOME/.config/Codex/User`

To copy your settings manually:

- In Visual Studio Code, go to Settings (Command+, if on a Mac)
- Click the three dots `...` and choose 'Open settings.json'
- Copy the contents of settings.json into the same place in Codex
