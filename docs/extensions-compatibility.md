# Extensions compatibility

## Partial Compatibility

- [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
> [Since May 2021](https://devblogs.microsoft.com/python/python-in-visual-studio-code-may-2021-release/), Python is using a closed source language server ([Pylance](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance))

## Incompatibility

- [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop)
> It's officially unsupported: https://github.com/James-Yu/LaTeX-Workshop/wiki/FAQ#vscodium-is-not-officially-supported

## Incompatibility due to licensing

The following extensions are not compatible with VSCodium due to their licensing:

- [Live Share](https://marketplace.visualstudio.com/items?itemName=MS-vsliveshare.vsliveshare)
- [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)
- [Remote - SSH: Editing Configuration Files](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh-edit)
- [Remote - WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)

## Replacements

The following extensions are functional replacements for incompatible extensions:

- [Open Remote - SSH](https://open-vsx.org/extension/jeanp413/open-remote-ssh)
- [Open Remote - WSL](https://open-vsx.org/extension/jeanp413/open-remote-wsl)
- [BasedPyright](https://open-vsx.org/extension/detachhead/basedpyright) (open-source alternative to Pylance)
