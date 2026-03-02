<!-- order: 25 -->

# Troubleshooting

## Table of Contents

- [Linux](#linux)
  - [Fonts showing up as rectangles](#linux-fonts-rectangle)
  - [Text and/or the entire interface not appearing](#linux-rendering-glitches)
  - [Global menu workaround for KDE](#linux-kde-global-menu)
  - [Flatpak most common issues](#linux-flatpak-most-common-issues)
  - [Remote SSH doesn't work](#linux-remote-ssh)
  - [The window doesn't show up](#linux-no-window)
- [Windows](#windows)
  - [Group Policy Objects (GPOs) are ignored](#windows-gpo)
  - ["Open with VSCodium" missing from context menu](#windows-context-menu)
  - [Windows Defender flags the installer as malware](#windows-defender)

## <a id="linux"></a>Linux

### <a id="linux-fonts-rectangle"></a>_Fonts showing up as rectangles_

The following command should help:

```
rm -rf ~/.cache/fontconfig
rm -rf ~/snap/codium/common/.cache
fc-cache -r
```

### <a id="linux-rendering-glitches"></a>_Text and/or the entire interface not appearing_

You have likely encountered [a bug in Chromium and Electron](microsoft/vscode#190437) when compiling Mesa shaders, which has affected all Visual Studio Code and VSCodium versions for Linux distributions since 1.82. The current workaround (see microsoft/vscode#190437) is to delete the GPU cache as follows:

```bash
rm -rf ~/.config/VSCodium/GPUCache
```

### <a id="linux-kde-global-menu"></a>_Global menu workaround for KDE_

Install these packages on Fedora:

- libdbusmenu-devel
- dbus-glib-devel
- libdbusmenu

On Ubuntu this package is called `libdbusmenu-glib4`.

Credits: [Gerson](https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/issues/91)

### <a id="linux-flatpak-most-common-issues"></a>_Flatpak most common issues_

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

### <a id="linux-remote-ssh"></a>_Remote SSH doesn't work_

Use the VSCodium's compatible extension [Open Remote - SSH](https://open-vsx.org/extension/jeanp413/open-remote-ssh).

On the server, in the `sshd` config, `AllowTcpForwarding` need to be set to `yes`.

It might requires additional dependencies due to the OS/distro (alpine).

### <a id="linux-no-window"></a>_The window doesn't show up_

If you are under Wayland:

- try the command `codium --verbose`
- if you see an error like `:ERROR:ui/gl/egl_util.cc:92] EGL Driver message (Error) eglCreateContext: Requested version is not supported`
- try `codium --ozone-platform=x11`

## <a id="windows"></a>Windows

### <a id="windows-gpo"></a>_Group Policy Objects (GPOs) are ignored_

VSCodium uses its own policy-watcher library (`@vscodium/policy-watcher`) which reads GPO values from a **different registry path** than VS Code.

**VSCodium reads policies from:**

```
HKLM\SOFTWARE\Policies\VSCodium\VSCodium
```

**VS Code reads policies from:**

```
HKLM\SOFTWARE\Policies\Microsoft\VSCode
```

If you are deploying VSCodium in an enterprise environment via Group Policy:

1. Copy the `.admx` template file to `C:\Windows\PolicyDefinitions\`
2. Copy the `.adml` language file to `C:\Windows\PolicyDefinitions\en-US\`
3. Open `gpedit.msc` and configure policies under the VSCodium group
4. Verify the resulting registry key exists at `HKLM\SOFTWARE\Policies\VSCodium\VSCodium` (not `Microsoft\VSCodium`)

If you set policies manually via Registry Editor, make sure you create the key at the correct path:

```
HKLM\SOFTWARE\Policies\VSCodium\VSCodium\<PolicyName>  (REG_SZ or REG_DWORD)
```

For example, to set `Update: Mode` to `none`:

```
Registry key: HKLM\SOFTWARE\Policies\VSCodium\VSCodium
Value name:   update.mode
Value type:   REG_SZ
Value data:   none
```

Per-user policies are also supported under `HKCU\SOFTWARE\Policies\VSCodium\VSCodium` (machine policies take precedence).

### <a id="windows-context-menu"></a>_"Open with VSCodium" missing from context menu_

If the **"Open with VSCodium"** option does not appear after installation (even with the checkbox checked during setup):

1. **Run the installer again** and ensure _"Add 'Open with VSCodium' action to Windows Explorer file context menu"_ is checked.
2. **Windows 11 note**: Windows 11 hides most context menu entries behind **Shift + Right-click** ("Show more options"). VSCodium's entry may be present but hidden in the new condensed menu. Try Shift + Right-click to see the classic context menu.
3. If the entry still does not appear, you can add it manually via Registry Editor:

   ```
   Key:   HKEY_CLASSES_ROOT\*\shell\Open with VSCodium
   Value: (Default) = "Open with VSCodium"

   Key:   HKEY_CLASSES_ROOT\*\shell\Open with VSCodium\command
   Value: (Default) = "C:\Program Files\VSCodium\VSCodium.exe" "%1"
   ```

   Adjust the install path to match your actual installation directory.

### <a id="windows-defender"></a>_Windows Defender flags the installer as malware_

Some users report Windows Defender detecting the VSCodium installer as `Cinjo` or another threat. This is a **false positive** caused by the unsigned nature of certain build artifacts.

- Download VSCodium **only from the official [GitHub Releases page](https://github.com/VSCodium/vscodium/releases)**.
- Verify the SHA256/SHA512 checksum of the downloaded file against the `.sha256` or `.sha512` file published alongside each release.
- If Defender blocks the installer, add an exclusion for the downloaded file, run the install, then remove the exclusion.
- You can also report the false positive directly to Microsoft via the [Windows Defender Security Intelligence submission portal](https://www.microsoft.com/en-us/wdsi/filesubmission).
