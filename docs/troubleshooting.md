<!-- order: 25 -->

# Troubleshooting

This page provides solutions to common issues encountered with VSCodium. Currently, it primarily focuses on Linux-related problems. Contributions for macOS and Windows troubleshooting are welcome!

## Table of Contents

- [Linux](#linux)
  - [Fonts showing up as rectangles](#linux-fonts-rectangle)
  - [Text and/or the entire interface not appearing (Rendering Glitches)](#linux-rendering-glitches)
  - [KDE Global Menu Integration Issues](#linux-kde-global-menu)
  - [Flatpak: Most Common Issues](#linux-flatpak-most-common-issues)
  - [Remote SSH Connection Problems](#linux-remote-ssh)

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

### <a id="linux-kde-global-menu"></a>*KDE Global Menu Integration Issues*

If the global menu in KDE Plasma does not integrate correctly with VSCodium, installing the following packages may resolve the issue:

On Fedora:

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

### <a id="linux-remote-ssh"></a>*Remote SSH Connection Problems*

If you're having trouble connecting to remote servers via SSH:

1.  **Use the Compatible Extension**: Ensure you are using the [Open Remote - SSH](https://open-vsx.org/extension/jeanp413/open-remote-ssh) extension, which is designed for VSCodium and other VS Code forks that use Open VSX. Microsoft's official Remote - SSH extension may not work.
2.  **Server Configuration**: On the SSH server, ensure that TCP forwarding is enabled. This typically means setting `AllowTcpForwarding yes` in your server's `sshd_config` file (usually located at `/etc/ssh/sshd_config`). Remember to restart the SSH service after making changes.
3.  **OS/Distro Specific Dependencies**: Some operating systems, particularly minimal ones like Alpine Linux, might require additional dependencies for the remote SSH functionality to work correctly. For Alpine, you may need to install packages such as `openssh-client`, `bash`, and ensure that `glibc` compatibility is handled if you're running pre-compiled binaries that depend on it. Investigating the output logs from the "Remote - SSH" extension in VSCodium can provide clues about missing dependencies.
