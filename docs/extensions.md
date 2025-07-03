<!-- order: 15 -->

# Extensions + Marketplace

## Table of Contents

- [Marketplace](#marketplace)
- [How to use the OpenVSX Marketplace](#howto-openvsx-marketplace)
- [How to use a different extension gallery](#howto-switch-marketplace)
- [How to self host your own extension gallery](#howto-selfhost-marketplace)
- [Visual Studio Marketplace](#visual-studio-marketplace)
- [Proprietary Debugging Tools](#proprietary-debugging-tools)
- [Proprietary Extensions](#proprietary-extensions)
- [Using the "VSIX Manager" Extension](#vsix-manager)
- [Extensions compatibility](https://github.com/VSCodium/vscodium/blob/master/docs/extensions-compatibility.md)

## <a id="marketplace"></a>Marketplace

Being a vscode based editor, VSCodium gets additional features by installing Visual Studio Code extensions.
Unfortunately, as Microsoft [prohibits usages of the Microsoft marketplace by any other products](https://github.com/microsoft/vscode/issues/31168) or redistribution of `.vsix` files from it, in order to use Visual Studio Code extensions in non-Microsoft products those need to be installed differently.

By default, the `product.json` file is set up to use [open-vsx.org](https://open-vsx.org/) as extension gallery, which has an [adapter](https://github.com/eclipse/openvsx/wiki/Using-Open-VSX-in-VS-Code) to the Marketplace API used by Visual Studio Code. Since that is a rather new project, you will likely miss some extensions you know from the Visual Studio Marketplace. You have the following options to obtain such missing extensions:

* Ask the extension maintainers to publish to [open-vsx.org](https://open-vsx.org/) in addition to the Visual Studio Marketplace. The publishing process is documented in the [Open VSX Wiki](https://github.com/eclipse/openvsx/wiki/Publishing-Extensions).
* Create a pull request to [this repository](https://github.com/open-vsx/publish-extensions) to have the [@open-vsx](https://github.com/open-vsx) service account publish the extensions for you.
* Download and [install the vsix files](https://code.visualstudio.com/docs/editor/extension-gallery#_install-from-a-vsix), for example from the release page in their source repository.

## <a id="howto-openvsx-marketplace"></a>How to use the Open VSX Registry

As noted above, the [Open VSX Registry](https://open-vsx.org/) is the pre-set extension gallery in VSCodium. Using the extension view in VSCodium will therefore by default use it.
See [this article](https://www.gitpod.io/blog/open-vsx/) for more information on the motivation behind Open VSX.

## <a id="howto-switch-marketplace"></a>How to use a different extension gallery

You can switch from the pre-set Open VSX Registry by configuring the endpoints using the following solutions.

You can either use the following environment variables:
- `VSCODE_GALLERY_SERVICE_URL` ***(required)***
- `VSCODE_GALLERY_ITEM_URL` ***(required)***
- `VSCODE_GALLERY_CACHE_URL`
- `VSCODE_GALLERY_CONTROL_URL`
- `VSCODE_GALLERY_EXTENSION_URL_TEMPLATE` ***(required)***
- `VSCODE_GALLERY_RESOURCE_URL_TEMPLATE`

Or by creating a custom `product.json` at the following location (replace `VSCodium` by `VSCodium - Insiders` if you use that):
- Windows: `%APPDATA%\VSCodium` or `%USERPROFILE%\AppData\Roaming\VSCodium`
- macOS: `~/Library/Application Support/VSCodium`
- Linux: `$XDG_CONFIG_HOME/VSCodium` or `~/.config/VSCodium`

with the content like:

```jsonc
{
  "extensionsGallery": {
    "serviceUrl": "", // required
    "itemUrl": "", // required
    "cacheUrl": "",
    "controlUrl": "",
    "extensionUrlTemplate": "", // required
    "resourceUrlTemplate": "",
  }
}
```

## <a id="howto-selfhost-marketplace"></a>How to self-host your own extension gallery

Individual developers and enterprise companies in regulated or security-conscious industries can self-host their own extension gallery.

There are likely other options, but the following were reported to work:

* [Open VSX](https://github.com/eclipse/openvsx) eclipse open-source project
  While the public instance which is run by the Eclipse Foundation is the pre-set endpoint in VSCodium, you can host your own instance.

    > Open VSX is a [vendor-neutral](https://projects.eclipse.org/projects/ecd.openvsx) open-source alternative to the [Visual Studio Marketplace](https://marketplace.visualstudio.com/vscode). It provides a server application that manages [Visual Studio Code extensions](https://code.visualstudio.com/api) in a database, a web application similar to the Visual Studio Marketplace, and a command-line tool for publishing extensions similar to [vsce](https://code.visualstudio.com/api/working-with-extensions/publishing-extension#vsce).

* [code-marketplace](https://coder.com/blog/running-a-private-vs-code-extension-marketplace) open-source project

    > `code-marketplace` is a self-contained go binary that does not have a frontend or any mechanisms for extension authors to add or update extensions in the marketplace. It simply reads extensions from file storage and provides an API for VSCode compatible editors to consume.

## <a id="visual-studio-marketplace"></a>Visual Studio Marketplace

As with any online service, ensure you've understood [its terms of use](https://aka.ms/vsmarketplace-ToU) which include:
> Marketplace Offerings are intended for use only with Visual Studio Products and Services and you may only install and use Marketplace Offerings with Visual Studio Products and Services.

So, we can't provide any help if you intend to infringe their terms of use.

Also note that this extension gallery hosts multiple extensions that are non-free and have license-agreements that explicitly forbid using them in non-Microsoft products, along with using telemetry.

## <a id="proprietary-debugging-tools"></a>Proprietary Debugging Tools

The debugger provided with Microsoft's [C# extension](https://github.com/OmniSharp/omnisharp-vscode) as well as the (Windows) debugger provided with their [C++ extension](https://github.com/Microsoft/vscode-cpptools) are very restrictively licensed to only work with the official Visual Studio Code build. See [this comment in the C# extension repo](https://github.com/OmniSharp/omnisharp-vscode/issues/2491#issuecomment-418811364) and [this comment in the C++ extension repo](https://github.com/Microsoft/vscode-cpptools/issues/21#issuecomment-248349017).

A workaround exists to get debugging working in C# projects, by using Samsung's opensource [netcoredbg](https://github.com/Samsung/netcoredbg) package. See [this comment](https://github.com/VSCodium/vscodium/issues/82#issue-409806641) for instructions on how to set that up.

## <a id="proprietary-extensions"></a>Proprietary Extensions

Like the debuggers mentioned above, some extensions you may find in the marketplace (like the [Remote Development Extensions](https://code.visualstudio.com/docs/remote/remote-overview)) only function with the official Visual Studio Code build. You can work around this by adding the extension's internal ID (found on the extension's page) to the `extensionAllowedProposedApi` property of the product.json in your VSCodium installation. For example:

```jsonc
  "extensionAllowedProposedApi": [
    // ...
    "ms-vscode-remote.vscode-remote-extensionpack", // Example: Enables the Remote Extension Pack
    "ms-vscode-remote.remote-wsl",                // Example: Enables Remote - WSL
    // ...
  ],
```
Note: While this configuration may allow certain proprietary extensions (like the Remote Development extensions shown) to activate in VSCodium, please be aware of their licensing terms. Many are restricted to official Visual Studio Code builds. For a list of known incompatible extensions and open-source alternatives, see [Extensions compatibility](https://github.com/VSCodium/vscodium/blob/master/docs/extensions-compatibility.md).

In some cases, the above change won't help because the extension is hard-coded to only work with the official Visual Studio Code product. It's also important to remember that enabling an extension via this method does not alter its license terms; if an extension's license restricts its use to official Microsoft Visual Studio Code builds, this method does not make its use in VSCodium compliant with those terms.

## <a id="vsix-manager"></a>Using the "VSIX Manager" Extension

The [**VSIX Manager**](https://github.com/zokugun/vscode-vsix-manager) extension provides a powerful and user-friendly interface for managing `.vsix` files directly within VSCodium. Its author is the main maintainer of VSCodium ;)

It is particularly beneficial for:
- **Support for Multiple Marketplaces**: Seamlessly install and manage extensions from several marketplaces at the same time, allowing access to a broader range of extensions.
- **Local Files**: Manage a collection of `.vsix` files stored locally.
- **GitHub/Forgejo Release**: Install the extension directly from its GitHub/Forgejo release pages.
- **Fallback Options**

### <a id="use-cases"></a>Use Cases

- Developers working offline can easily manage `.vsix` files.
- Teams can distribute specific versions of extensions across systems.
- Enterprises with restricted environments can maintain control over installed extensions.
- Users can connect to multiple marketplaces and access a wider range of extensions or switch seamlessly between them.

### <a id="marketplace-support"></a>Marketplace Support

The **VSIX Manager** extension supports managing extensions from several marketplaces simultaneously. This feature enables:
- **Access to Diverse Extensions**: Install extensions from different sources like Open VSX or private repositories.
- **Fallback Options**: Ensure extension availability even if one marketplace is temporarily inaccessible.
- **Enterprise Flexibility**: Use private or self-hosted marketplaces alongside public ones to meet security and compliance requirements.
- **Custom Configurations**: Prioritize specific marketplaces for particular needs while keeping access to others.

## [Extensions compatibility](https://github.com/VSCodium/vscodium/blob/master/docs/extensions-compatibility.md)

