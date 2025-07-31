<!-- order: 0 -->

# Extensions compatibility

## Table of Contents

- [Incompatibility](#incompatibility)
- [Replacements](#replacements)
  - [C/C++](#cc)
  - [Python](#python)
  - [Remote](#remote)
- [Beyond](#beyond)

## Incompatibility

Most MS extensions are limited to run on only MS products by their license and by running additional checks in their proprietary code.

- [C/C++](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
- [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop)
> It's officially unsupported: https://github.com/James-Yu/LaTeX-Workshop/wiki/FAQ#codex-is-not-officially-supported

## Incompatibility due to licensing

The following extensions are not compatible with Codex due to their licensing:

- [Live Share](https://marketplace.visualstudio.com/items?itemName=MS-vsliveshare.vsliveshare)
- [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
- [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)
- [Remote - SSH: Editing Configuration Files](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh-edit)
- [Remote - WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)

## Replacements

The following extensions are functional replacements for incompatible extensions:

### C/C++

- [clangd](https://open-vsx.org/extension/llvm-vs-code-extensions/vscode-clangd)

### Python

- [BasedPyright](https://open-vsx.org/extension/detachhead/basedpyright)

### Remote

- [Open Remote - SSH](https://open-vsx.org/extension/jeanp413/open-remote-ssh)
> SSH server must be configured with the setting `AllowTcpForwarding yes`.
- [Open Remote - WSL](https://open-vsx.org/extension/jeanp413/open-remote-wsl)

## Beyond

[VSIX Manager](https://github.com/zokugun/vscode-vsix-manager) allows you to be able install extensions from multiple sources.
