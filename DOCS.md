# More Info

## Table of Contents
- [Getting all the Telemetry Out](#disable-telemetry)
- [Extensions + Marketplace](#extensions-marketplace)
- [Migrating from Visual Studio Code to VSCodium](#migrating)
- [How do I press and hold a key and have it repeat in VSCodium?](#press-and-hold)
- [How do I open VSCodium from the terminal?](#terminal-support)

## <a id="disable-telemetry"></a>Getting all the Telemetry Out
Even though we do not pass the telemetry build flags (and go out of our way to cripple the baked-in telemetry), Microsoft will still track usage by default.

We do however set the default `telemetry.enableCrashReporter` and `telemetry.enableTelemetry` values to false. You can see those by viewing your VSCodium settings.json and searching for `telemetry`.

The instructions [here](https://code.visualstudio.com/docs/supporting/faq#_how-to-disable-telemetry-reporting) and [here](https://code.visualstudio.com/docs/supporting/faq#_how-to-disable-crash-reporting) help with explaining and toggling telemetry. 

It is also highly recommended that you review all the settings that "use online services" by following [these instructions](https://code.visualstudio.com/docs/supporting/faq#_managing-online-services). The `@tag:usesOnlineServices` filter on the settings page will show that by default:
- Extensions auto check for updates and auto install updates
- Searches within the app are sent to an online service for "natural language processing"
- Updates to the app are fetched in the background

These can all be disabled.

__Please note that some extensions send telemetry data to Microsoft as well. We have no control over this and can only recommend removing the extension.__

_(For example the C# extension `ms-vscode.csharp` sends tracking data to Microsoft.)_

## <a id="extensions-marketplace"></a>Extensions + Marketplace
Until something more open comes around, we use the Microsoft Marketplace/Extensions in the `product.json` file. Those links are licensed under MIT as per [the comments on this issue.](https://github.com/Microsoft/vscode/issues/31168#issuecomment-317319063)

If you use the [code-settings-sync](https://github.com/shanalikhan/code-settings-sync) extension, you may have [an issue](https://github.com/VSCodium/vscodium/issues/72) installing extensions (via the plugin). Refer to [this workaround](https://github.com/shanalikhan/code-settings-sync/issues/668#issuecomment-462065341) to get it working properly.

### Proprietary Debugging Tools
The debugger provided with Microsoft's [C# extension](https://github.com/OmniSharp/omnisharp-vscode) as well as the (Windows) debugger provided with their [C++ extension](https://github.com/Microsoft/vscode-cpptools) are very restrictively licensed to only work with the offical Visual Studio Code build. See [this comment in the C# extension repo](https://github.com/OmniSharp/omnisharp-vscode/issues/2491#issuecomment-418811364) and [this comment in the C++ extension repo](https://github.com/Microsoft/vscode-cpptools/issues/21#issuecomment-248349017). 

A workaround exists to get debugging working in C# projects, by using Samsung's opensource [netcoredbg](https://github.com/Samsung/netcoredbg) package. See [this comment](https://github.com/VSCodium/vscodium/issues/82#issue-409806641) for instructions on how to set that up.

## <a id="migrating"></a>Migrating from Visual Studio Code to VSCodium
VSCodium (and a freshly cloned copy of vscode built from source) stores its extension files in `~/.vscode-oss`. So if you currently have Visual Studio Code installed, your extensions won't automatically populate. You can reinstall your extensions from the Marketplace in VSCodium, or copy the `extensions` from `~/.vscode/extensions` to `~/.vscode-oss/extensions`.

Visual Studio Code stores its `keybindings.json` and `settings.json` file in the these locations:
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

## <a id="press-and-hold"></a>How do I press and hold a key and have it repeat in VSCodium (Mac)?
This is a common question for Visual Studio Code and the procedure is slightly different in VSCodium because the `defaults` path is different.

```bash
$ defaults write com.visualstudio.code.oss ApplePressAndHoldEnabled -bool false
```

## <a id="terminal-support"></a>How do I open VSCodium from the terminal?
- Go to the command palette (View | Command Palette...)
- Choose `Shell command: Install 'vscodium' command in PATH`.

![](https://user-images.githubusercontent.com/2707340/45751224-bd21a500-bbdf-11e8-8fb7-b645b97aae49.png)

This allows you to open files or directories in VSCodium directly from your terminal:

```bash
~/in-my-project $ vscodium . # open this directory
~/in-my-project $ vscodium file.txt # open this file
```

Feel free to alias this command to something easier to type in your shell profile (e.g. `alias code=vscodium`).
