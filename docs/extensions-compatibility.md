<!-- order: 0 -->

# Extensions compatibility

## Table of Contents

- [Incompatibility](#incompatibility)
- [Replacements](#replacements)
  - [C/C++](#cc)
  - [Python](#python)
  - [Remote](#remote)

## <a id="incompatibility"></a>Incompatibility

Most MS extensions are limited to run on only MS products by their license and by running additional checks in their proprietary code.

- [C/C++](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
- [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop)
> It's officially unsupported: https://github.com/James-Yu/LaTeX-Workshop/wiki/FAQ#vscodium-is-not-officially-supported
- [Live Share](https://marketplace.visualstudio.com/items?itemName=MS-vsliveshare.vsliveshare)
- [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
- [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)
- [Remote - SSH: Editing Configuration Files](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh-edit)
- [Remote - WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)

## <a id="replacements"></a>Replacements

The following extensions are functional replacements for incompatible extensions:

### <a id="cc"></a>C/C++

- [clangd](https://open-vsx.org/extension/llvm-vs-code-extensions/vscode-clangd) for full featured editing (including IntelliSense)
- [Native Debug](https://open-vsx.org/extension/webfreak/debug) for Debugging with GDB + LLDB  
  Note that there are many working debugging extensions and specialized ones including for microcontrollers.

### <a id="python"></a>Python

- [BasedPyright](https://open-vsx.org/extension/detachhead/basedpyright)

### <a id="remote"></a>Remote Development

- [Open Remote - SSH](https://open-vsx.org/extension/jeanp413/open-remote-ssh)
> SSH server must be configured with the setting `AllowTcpForwarding yes`.
- [Open Remote - WSL](https://open-vsx.org/extension/jeanp413/open-remote-wsl)

---

*This list is not exhaustive. The world of VS Code extensions is constantly evolving. We encourage users to search for alternatives on [Open VSX](https://open-vsx.org/) and to [contribute](https://github.com/VSCodium/vscodium/blob/master/CONTRIBUTING.md) if they find new incompatibilities or viable open-source replacements.*
