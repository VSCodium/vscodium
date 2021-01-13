# More Info

## Table of Contents

- [Getting all the Telemetry Out](#disable-telemetry)
- [Extensions + Marketplace](#extensions-marketplace)
- [Migrating from Visual Studio Code to VSCodium](#migrating)
- [How do I run VSCodium in portable mode?](#portable)
- [How do I press and hold a key and have it repeat in VSCodium?](#press-and-hold)
- [How do I open VSCodium from the terminal?](#terminal-support)
- [Gentoo overlay/ebuild](#gentoo-overlay)

## <a id="disable-telemetry"></a>Getting all the Telemetry Out

Even though we do not pass the telemetry build flags (and go out of our way to cripple the baked-in telemetry), Microsoft will still track usage by default.

We do however set the default `telemetry.enableCrashReporter` and `telemetry.enableTelemetry` values to false. You can see those by viewing your VSCodium settings.json and searching for `telemetry`.

The instructions [here](https://code.visualstudio.com/docs/supporting/faq#_how-to-disable-telemetry-reporting) and [here](https://code.visualstudio.com/docs/supporting/faq#_how-to-disable-crash-reporting) help with explaining and toggling telemetry.

It is also highly recommended that you review all the settings that "use online services" by following [these instructions](https://code.visualstudio.com/docs/getstarted/telemetry#_managing-online-services). The `@tag:usesOnlineServices` filter on the settings page will show that by default:

- Extensions auto check for updates and auto install updates
- Searches within the app are sent to an online service for "natural language processing"
- Updates to the app are fetched in the background

These can all be disabled.

__Please note that some extensions send telemetry data to Microsoft as well. We have no control over this and can only recommend removing the extension.__ _(For example, the C# extension `ms-vscode.csharp` sends tracking data to Microsoft.)_

### Replacements to Microsoft Online Services

When searching the `@tag:usesOnlineServices` filter, note that while the "Update: Mode" setting description still says "The updates are fetched from a Microsoft online service", VSCodium's build script [sets the `updateUrl` field](https://github.com/VSCodium/vscodium/blob/master/prepare_vscode.sh#L36) in `product.json` to that of VSCodium's own small [update server](https://github.com/VSCodium/update-api), so enabling that setting won't actually result in any calls to Microsoft servers.

Likewise, while the descriptions for "Extensions: Auto Check Updates" and "Extensions: Auto Update" include the same phrase, VSCodium [replaces](https://github.com/VSCodium/vscodium/blob/master/prepare_vscode.sh#L42) the Visual Studio Marketplace with Open VSX, so these settings won't call Microsoft, either.

## <a id="extensions-marketplace"></a>Extensions + Marketplace

The `product.json` file is set up to use [open-vsx.org](https://open-vsx.org/) as extension gallery, which has an [adapter](https://github.com/eclipse/openvsx/wiki/Using-Open-VSX-in-VS-Code) to the Marketplace API used by VS Code. Since that is a rather new project, you will likely miss some extensions you know from the VS Code Marketplace. You have the following options to obtain such missing extensions:

* Ask the extension maintainers to publish to [open-vsx.org](https://open-vsx.org/) in addition to the VS Code Marketplace. The publishing process is documented in the [Open VSX Wiki](https://github.com/eclipse/openvsx/wiki/Publishing-Extensions).
* Create a pull request to [this repository](https://github.com/open-vsx/publish-extensions) to have the [@open-vsx](https://github.com/open-vsx) service account publish the extensions for you.
* Download and [install the vsix files](https://code.visualstudio.com/docs/editor/extension-gallery#_install-from-a-vsix).
* Modify the `extensionsGallery` section of the `product.json` file in your VSCodium installation to use the VS Code Marketplace as shown below. However, note that [it is not clear whether this is legal](https://github.com/microsoft/vscode/issues/31168).
  ```json
  "extensionsGallery": {
      "serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery",
      "itemUrl": "https://marketplace.visualstudio.com/items"
  }
  ```

See [this article](https://www.gitpod.io/blog/open-vsx/) for more information on the motivation behind Open VSX.

### Proprietary Debugging Tools

The debugger provided with Microsoft's [C# extension](https://github.com/OmniSharp/omnisharp-vscode) as well as the (Windows) debugger provided with their [C++ extension](https://github.com/Microsoft/vscode-cpptools) are very restrictively licensed to only work with the offical Visual Studio Code build. See [this comment in the C# extension repo](https://github.com/OmniSharp/omnisharp-vscode/issues/2491#issuecomment-418811364) and [this comment in the C++ extension repo](https://github.com/Microsoft/vscode-cpptools/issues/21#issuecomment-248349017).

A workaround exists to get debugging working in C# projects, by using Samsung's opensource [netcoredbg](https://github.com/Samsung/netcoredbg) package. See [this comment](https://github.com/VSCodium/vscodium/issues/82#issue-409806641) for instructions on how to set that up.

### Proprietary Extensions

Like the debuggers mentioned above, some extensions you may find in the marketplace (like the [Remote Development Extensions](https://code.visualstudio.com/docs/remote/remote-overview)) only function with the offical Visual Studio Code build. You can work around this by adding the extension's internal ID (found on the extension's page) to the `extensionAllowedProposedApi` property of the product.json in your VSCodium installation. For example:

```json
  "extensionAllowedProposedApi": [
    // ...
    "ms-vscode-remote.vscode-remote-extensionpack",
    "ms-vscode-remote.remote-wsl",
    // ...
  ],
```

In some cases, the above change won't help because the extension is hard-coded to only work with the official Visual Studio Code product.

## <a id="migrating"></a>Migrating from Visual Studio Code to VSCodium

VSCodium (and a freshly cloned copy of vscode built from source) stores its extension files in `~/.vscode-oss`. So if you currently have Visual Studio Code installed, your extensions won't automatically populate. You can reinstall your extensions from the Marketplace in VSCodium, or copy the `extensions` from `~/.vscode/extensions` to `~/.vscode-oss/extensions`.

Visual Studio Code stores its `keybindings.json` and `settings.json` file in these locations:

- __Windows__: `%APPDATA%\Code\User`
- __macOS__: `$HOME/Library/Application Support/Code/User`
- __Linux__: `$HOME/.config/Code/User`

You can copy these files to the VSCodium user settings folder:

- __Windows__: `%APPDATA%\VSCodium\User`
- __macOS__: `$HOME/Library/Application Support/VSCodium/User`
- __Linux__: `$HOME/.config/VSCodium/User`

To copy your settings manually:

- In Visual Studio Code, go to Settings (Command+, if on a Mac)
- Click the three dots `...` and choose 'Open settings.json'
- Copy the contents of settings.json into the same place in VSCodium

## <a id="portable"></a>How do I run VSCodium in portable mode?
You can follow the [Portable Mode instructions](https://code.visualstudio.com/docs/editor/portable) from the Visual Studio Code website. 
- **Windows** / **Linux** : the instructions can be followed as written.
- **macOS** : portable mode is enabled by the existence of a specially named folder. For Visual Studio Code that folder name is `code-portable-data`. For VSCodium, that folder name is `codium-portable-data`. So to enable portable mode for VSCodium on Mac OS, follow the instructions outlined in the [link above](https://code.visualstudio.com/docs/editor/portable), but create a folder named `codium-portable-data` instead of `code-portable-data`.

## <a id="press-and-hold"></a>How do I press and hold a key and have it repeat in VSCodium (Mac)?

This is a common question for Visual Studio Code and the procedure is slightly different in VSCodium because the `defaults` path is different.

```bash
$ defaults write com.visualstudio.code.oss ApplePressAndHoldEnabled -bool false
```

## <a id="terminal-support"></a>How do I open VSCodium from the terminal?

- Go to the command palette (View | Command Palette...)
- Choose `Shell command: Install 'codium' command in PATH`.

![](https://user-images.githubusercontent.com/2707340/60140295-18338a00-9766-11e9-8fda-b525b6f15c13.png)

This allows you to open files or directories in VSCodium directly from your terminal:

```bash
~/in-my-project $ codium . # open this directory
~/in-my-project $ codium file.txt # open this file
```

Feel free to alias this command to something easier to type in your shell profile (e.g. `alias code=codium`).

## <a id="gentoo-overlay"></a>Gentoo ebuild/overlay

There is an external Gentoo overlay with a working ebuild to install VSCodium, provided by [@wolviecb](https://github.com/wolviecb/). The overlay can be found [here](https://github.com/wolviecb/overlay).
