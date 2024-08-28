# Troubleshooting

## Table of Contents

- [Linux](#linux)
  - [Fonts showing up as rectangles](#linux-fonts-rectangle)
  - [Global menu workaround for KDE](#linux-kde-global-menu)
  - [Flatpak most common issues](#linux-flatpak-most-common-issues)
<<<<<<< HEAD
  - [Remote SSH doesn't work](#linux-remote-ssh)
=======
>>>>>>> e7fd12ed78911b9f7e12bf5c5bf04af45d65144b
- [macOS](#macos)
  - [App can't be opened because Apple cannot check it for malicious software](#macos-unidentified-developer)
  - ["Codex.app" is damaged and can’t be opened. You should move it to the Bin](#macos-quarantine)


## <a id="linux"></a>Linux

#### <a id="linux-fonts-rectangle"></a>*Fonts showing up as rectangles*

The following command should help:

```
rm -rf ~/.cache/fontconfig
rm -rf ~/snap/codex/common/.cache
fc-cache -r
```

#### <a id="linux-kde-global-menu"></a>*Global menu workaround for KDE*

Install these packages on Fedora:

* libdbusmenu-devel
* dbus-glib-devel
* libdbusmenu

On Ubuntu this package is called `libdbusmenu-glib4`.

Credits: [Gerson](https://gitlab.com/paulcarroty/codex-deb-rpm-repo/-/issues/91)

#### <a id="linux-flatpak-most-common-issues"></a>*Flatpak most common issues*

- blurry screen with HiDPI on wayland run:
  ```bash
  flatpak override --user --nosocket=wayland com.codex.codex
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
  see [this](https://github.com/flathub/com.codex.codex?tab=readme-ov-file#sdks)

- If you have any other problems with the flatpak package try to look on the [FAQ](https://github.com/flathub/com.codex.codex?tab=readme-ov-file#faq) maybe the solution is already there or open an [issue](https://github.com/flathub/com.codex.codex/issues).

##### <a id="linux-remote-ssh"></a>*Remote SSH doesn't work*

Use the Codex's compatible extension [Open Remote - SSH](https://open-vsx.org/extension/jeanp413/open-remote-ssh).

On the server, in the `sshd` config, `AllowTcpForwarding` need to be set to `yes`.

It might requires additional dependeincies due to the OS/distro (alpine).

## <a id="macos"></a>macOS

Since the App is signed with a self-signed certificate, on the first launch, you might see the following messages:

#### <a id="macos-unidentified-developer"></a>*App can't be opened because Apple cannot check it for malicious software*

You can right-click the App and choose `Open`.

#### <a id="macos-quarantine"></a>*"Codex.app" is damaged and can’t be opened. You should move it to the Bin.*

The following command will remove the quarantine attribute.

```
xattr -r -d com.apple.quarantine /Applications/Codex.app
```
