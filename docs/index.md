# More Info

## Table of Contents

- [Getting all the Telemetry Out](#disable-telemetry)
  - [Replacements to Microsoft Online Services](#replacement-online-services)
- [Extensions + Marketplace](#extensions-marketplace)
  - [How to use the OpenVSX Marketplace](#howto-openvsx-marketplace)
  - [How to use the VS Code Marketplace](#howto-vscode-marketplace)
  - [How to self host your own VS Code Marketplace](#howto-selfhost-marketplace)
  - [Proprietary Debugging Tools](#proprietary-debugging-tools)
  - [Proprietary Extensions](#proprietary-extensions)
- [Extensions compatibility](https://github.com/VSCodium/vscodium/blob/master/docs/extensions-compatibility.md)
- [Migrating from Visual Studio Code to VSCodium](#migrating)
- [Sign in with GitHub](#signin-github)
- [Accounts authentication](https://github.com/VSCodium/vscodium/blob/master/docs/accounts-authentication.md)
- [How do I run VSCodium in portable mode?](#portable)
- [How do I fix the default file manager?](#file-manager)
- [How do I press and hold a key and have it repeat in VSCodium?](#press-and-hold)
- [How do I open VSCodium from the terminal?](#terminal-support)
  - [From Linux .tar.gz](#from-linux-targz)
- [Troubleshooting](https://github.com/VSCodium/vscodium/blob/master/docs/troubleshooting.md)
- [Contributing](https://github.com/VSCodium/vscodium/blob/master/CONTRIBUTING.md)
- [How to build VSCodium](https://github.com/VSCodium/vscodium/blob/master/docs/howto-build.md)

## <a id="disable-telemetry"></a>Getting all the Telemetry Out

Even though we do not pass the telemetry build flags (and go out of our way to cripple the baked-in telemetry), Microsoft will still track usage by default.

We do however set the `telemetry.enableTelemetry` setting's default value to `false`. You can see those by viewing your VSCodium `settings.json` and searching for `telemetry`.

The instructions [here](https://code.visualstudio.com/docs/supporting/faq#_how-to-disable-telemetry-reporting) help with explaining and toggling telemetry.

It is also highly recommended that you review all the settings that "use online services" by following [these instructions](https://code.visualstudio.com/docs/getstarted/telemetry#_managing-online-services). The `@tag:usesOnlineServices` filter on the settings page will show that by default:

- Extensions auto check for updates and auto install updates
- Searches within the app are sent to an online service for "natural language processing"
- Updates to the app are fetched in the background

These can all be disabled.

__Please note that some extensions send telemetry data to Microsoft as well. We have no control over this and can only recommend removing the extension.__ _(For example, the C# extension `ms-vscode.csharp` sends tracking data to Microsoft.)_

### <a id="replacement-online-services"></a>Replacements to Microsoft Online Services

When searching the `@tag:usesOnlineServices` filter, note that while the "Update: Mode" setting description still says "The updates are fetched from a Microsoft online service", VSCodium's build script [sets the `updateUrl` field](https://github.com/VSCodium/vscodium/blob/master/prepare_vscode.sh#L36) in `product.json` to that of VSCodium's own small [update server](https://github.com/VSCodium/update-api), so enabling that setting won't actually result in any calls to Microsoft servers.

Likewise, while the descriptions for "Extensions: Auto Check Updates" and "Extensions: Auto Update" include the same phrase, VSCodium [replaces](https://github.com/VSCodium/vscodium/blob/master/prepare_vscode.sh#L42) the Visual Studio Marketplace with Open VSX, so these settings won't call Microsoft, either.

## <a id="extensions-marketplace"></a>Extensions + Marketplace

Being a vscode based editor, VSCodium gets additional features by installing VS Code extensions.
Unfortunately, as Microsoft [prohibits usages of the Microsoft marketplace by any other products](https://github.com/microsoft/vscode/issues/31168) or redistribution of `.vsix` files from it, in order to use VS Code extensions in non-Microsoft products those need to be installed differently.

By default, the `product.json` file is set up to use [open-vsx.org](https://open-vsx.org/) as extension gallery, which has an [adapter](https://github.com/eclipse/openvsx/wiki/Using-Open-VSX-in-VS-Code) to the Marketplace API used by VS Code. Since that is a rather new project, you will likely miss some extensions you know from the VS Code Marketplace. You have the following options to obtain such missing extensions:

* Ask the extension maintainers to publish to [open-vsx.org](https://open-vsx.org/) in addition to the VS Code Marketplace. The publishing process is documented in the [Open VSX Wiki](https://github.com/eclipse/openvsx/wiki/Publishing-Extensions).
* Create a pull request to [this repository](https://github.com/open-vsx/publish-extensions) to have the [@open-vsx](https://github.com/open-vsx) service account publish the extensions for you.
* Download and [install the vsix files](https://code.visualstudio.com/docs/editor/extension-gallery#_install-from-a-vsix), for example from the release page in their source repository.

### <a id="howto-openvsx-marketplace"></a>How to use the Open VSX Registry

As noted above, the [Open VSX Registry](https://open-vsx.org/) is the pre-set extension gallery in VSCodium. Using the extension view in VSCodium will therefore by default use it.
See [this article](https://www.gitpod.io/blog/open-vsx/) for more information on the motivation behind Open VSX.

### <a id="howto-switch-marketplace"></a>How to use a different extension gallery

You can switch from the pre-set Open VSX Registry by configuring the endpoints using the following solutions.
These examples use the URLs for Microsoft's VS Code Marketplace, see [below](#howto-vscode-marketplace) for more information on that.

With the following environment variables:
- `VSCODE_GALLERY_SERVICE_URL='https://marketplace.visualstudio.com/_apis/public/gallery'`
- `VSCODE_GALLERY_ITEM_URL='https://marketplace.visualstudio.com/items'`
- `VSCODE_GALLERY_CACHE_URL='https://vscode.blob.core.windows.net/gallery/index'`
- `VSCODE_GALLERY_CONTROL_URL=''`

Or by creating a custom `product.json` at the following location (replace `VSCodium` by `VSCodium - Insiders` if you use that):
- Windows: `%APPDATA%\VSCodium` or `%USERPROFILE%\AppData\Roaming\VSCodium`
- macOS: `~/Library/Application Support/VSCodium`
- Linux: `$XDG_CONFIG_HOME/VSCodium` or `~/.config/VSCodium`

with the content:

- Note: set `cacheUrl` to empty string for every other extension gallery

```jsonc
{
  "extensionsGallery": {
    "serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery",
    "itemUrl": "https://marketplace.visualstudio.com/items",
    "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index",
    "controlUrl": ""
  }
}
```

### <a id="howto-selfhost-marketplace"></a>How to self-host your own extension gallery

Individual developers and enterprise companies in regulated or security-conscious industries can self-host their own extension gallery. In all of these cases, you'd enter its endpoint URLs as noted above, replacing `marketplace.visualstudio.com` with `your-self-hosted-marketplace-address.example.com` (or IP address), setting `cacheUrl` / `VSCODE_GALLERY_CACHE_URL` to an empty string.

There are likely other options, but the following were reported to work:

* [Open VSX](https://github.com/eclipse/openvsx) eclipse open-source project
  While the public instance which is run by the Eclipse Foundation is the pre-set endpoint in VSCodium, you can host your own instance.

    > Open VSX is a [vendor-neutral](https://projects.eclipse.org/projects/ecd.openvsx) open-source alternative to the [Visual Studio Marketplace](https://marketplace.visualstudio.com/vscode). It provides a server application that manages [VS Code extensions](https://code.visualstudio.com/api) in a database, a web application similar to the VS Code Marketplace, and a command-line tool for publishing extensions similar to [vsce](https://code.visualstudio.com/api/working-with-extensions/publishing-extension#vsce).

* [code-marketplace](https://coder.com/blog/running-a-private-vs-code-extension-marketplace) open-source project

    > `code-marketplace` is a self-contained go binary that does not have a frontend or any mechanisms for extension authors to add or update extensions in the marketplace. It simply reads extensions from file storage and provides an API for VSCode compatible editors to consume.

### <a id="howto-vscode-marketplace"></a>How to use the VS Code Marketplace

As with any online service, ensure you've understood [its terms of use](https://aka.ms/vsmarketplace-ToU).
Also note that this extension gallery hosts multiple extensions that are non-free and have license-agreements that explicitly forbid using them in non-Microsoft products, along with using telemetry.

The endpoint URLs are given in the [example above](#howto-switch-marketplace).


### <a id="proprietary-debugging-tools"></a>Proprietary Debugging Tools

The debugger provided with Microsoft's [C# extension](https://github.com/OmniSharp/omnisharp-vscode) as well as the (Windows) debugger provided with their [C++ extension](https://github.com/Microsoft/vscode-cpptools) are very restrictively licensed to only work with the official Visual Studio Code build. See [this comment in the C# extension repo](https://github.com/OmniSharp/omnisharp-vscode/issues/2491#issuecomment-418811364) and [this comment in the C++ extension repo](https://github.com/Microsoft/vscode-cpptools/issues/21#issuecomment-248349017).

A workaround exists to get debugging working in C# projects, by using Samsung's opensource [netcoredbg](https://github.com/Samsung/netcoredbg) package. See [this comment](https://github.com/VSCodium/vscodium/issues/82#issue-409806641) for instructions on how to set that up.

### <a id="proprietary-extensions"></a>Proprietary Extensions

Like the debuggers mentioned above, some extensions you may find in the marketplace (like the [Remote Development Extensions](https://code.visualstudio.com/docs/remote/remote-overview)) only function with the official Visual Studio Code build. You can work around this by adding the extension's internal ID (found on the extension's page) to the `extensionAllowedProposedApi` property of the product.json in your VSCodium installation. For example:

```jsonc
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

## <a id="signin-github"></a>Sign in with GitHub

In VSCodium, `Sign in with GitHub` is using a Personal Access Token.<br />
Follow the documentation https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token to create your token.<br />
Select the scopes dependending on the extension which needs access to GitHub. (GitLens requires the `repo` scope.)

### Linux

If you are getting the error `Writing login information to the keychain failed with error 'The name org.freedesktop.secrets was not provided by any .service files'.`, you need to install the package `gnome-keyring`.

## <a id="portable"></a>How do I run VSCodium in portable mode?
You can follow the [Portable Mode instructions](https://code.visualstudio.com/docs/editor/portable) from the Visual Studio Code website.
- **Windows** / **Linux** : the instructions can be followed as written.
- **macOS** : portable mode is enabled by the existence of a specially named folder. For Visual Studio Code that folder name is `code-portable-data`. For VSCodium, that folder name is `codium-portable-data`. So to enable portable mode for VSCodium on Mac OS, follow the instructions outlined in the [link above](https://code.visualstudio.com/docs/editor/portable), but create a folder named `codium-portable-data` instead of `code-portable-data`.

## <a id="file-manager"></a>How do I fix the default file manager (Linux)?

In some cases, VSCodium becomes the file manager used to open directories (instead of apps like Dolphin or Nautilus).<br />
It's due to that no application was defined as the default file manager and so the system is using the latest capable application.

To set the default app, create the file `~/.config/mimeapps.list` with the content like:
```
[Default Applications]
inode/directory=org.gnome.Nautilus.desktop;
```

You can find your regular file manager with the command:
```
> grep directory /usr/share/applications/mimeinfo.cache
inode/directory=codium.desktop;org.gnome.Nautilus.desktop;
```

## <a id="press-and-hold"></a>How do I press and hold a key and have it repeat in VSCodium (Mac)?

This is a common question for Visual Studio Code and the procedure is slightly different in VSCodium because the `defaults` path is different.

```bash
$ defaults write com.vscodium ApplePressAndHoldEnabled -bool false
```

## <a id="terminal-support"></a>How do I open VSCodium from the terminal?

For macOS and Windows:
- Go to the command palette (View | Command Palette...)
- Choose `Shell command: Install 'codium' command in PATH`.

![](https://user-images.githubusercontent.com/2707340/60140295-18338a00-9766-11e9-8fda-b525b6f15c13.png)

This allows you to open files or directories in VSCodium directly from your terminal:

```bash
~/in-my-project $ codium . # open this directory
~/in-my-project $ codium file.txt # open this file
```

Feel free to alias this command to something easier to type in your shell profile (e.g. `alias code=codium`).

On Linux, when installed with a package manager, `codium` has been installed in your `PATH`.

### <a id="from-linux-targz"></a>From Linux .tar.gz

When the archive `VSCodium-linux-<arch>-<version>.tar.gz` is extracted, the main entry point for VSCodium is `./bin/codium`.
