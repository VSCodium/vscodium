<!-- order: 25 -->

# Troubleshooting

## Table of Contents

- [Linux](#linux)
  - [Fonts showing up as rectangles](#linux-fonts-rectangle)
  - [Text and/or the entire interface not appearing](#linux-rendering-glitches)
  - [Global menu workaround for KDE](#linux-kde-global-menu)
  - [Flatpak most common issues](#linux-flatpak-most-common-issues)
  - [Remote SSH doesn't work](#linux-remote-ssh)

## <a id="linux"></a>Linux

### <a id="linux-fonts-rectangle"></a>*Fonts showing up as rectangles*

The following command should help:

```
rm -rf ~/.cache/fontconfig
rm -rf ~/snap/codium/common/.cache
fc-cache -r
```

### <a id="linux-rendering-glitches"></a>*Text and/or the entire interface not appearing*

You have likely encountered [a bug in Chromium and Electron](microsoft/vscode#190437) when compiling Mesa shaders, which has affected all Visual Studio Code and VSCodium versions for Linux distributions since 1.82.  The current workaround (see microsoft/vscode#190437) is to delete the GPU cache as follows:

```bash
rm -rf ~/.config/VSCodium/GPUCache
```

### <a id="linux-kde-global-menu"></a>*Global menu workaround for KDE*

Install these packages on Fedora:

* libdbusmenu-devel
* dbus-glib-devel
* libdbusmenu

On Ubuntu this package is called `libdbusmenu-glib4`.

Credits: [Gerson](https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/issues/91)

### <a id="linux-flatpak-most-common-issues"></a>*Flatpak most common issues*

- blurry screen with HiDPI on wayland run:
  ```bash
  flatpak override --user --nosocket=wayland com.vscodium.codium
  ```
- To execute commands on the host system, run inside the sandbox
  ```bash
  flatpak-spawn --host <COMMAND>
  # or
  host-spawn <COMMAND>
  ```
- Where is my X extension? AKA modify product.json
  TL;DR: use https://open-vsx.org/extension/zokugun/vsix-manager

- SDKs
  see [this](https://github.com/flathub/com.vscodium.codium?tab=readme-ov-file#sdks)

- If you have any other problems with the flatpak package try to look on the [FAQ](https://github.com/flathub/com.vscodium.codium?tab=readme-ov-file#faq) maybe the solution is already there or open an [issue](https://github.com/flathub/com.vscodium.codium/issues).

### <a id="linux-remote-ssh"></a>*Remote SSH doesn't work*

Use the VSCodium's compatible extension [Open Remote - SSH](https://open-vsx.org/extension/jeanp413/open-remote-ssh).

On the server, in the `sshd` config, `AllowTcpForwarding` need to be set to `yes`.

It might requires additional dependencies due to the OS/distro (alpine).
