---
title: "Backends | mise-en-place"
meta:
  description: "mise-en-place documentation"
---

# Backends [​](#backends)

Backends are package managers or ecosystems that mise uses to install [tools](https://mise.jdx.dev/dev-tools/index.html) and [plugins](https://mise.jdx.dev/plugins.html). Each backend can install and manage multiple tools from its ecosystem. For example, the `npm` backend can install many different tools like `npm:prettier`, or the `pipx` backend can install tools like `pipx:black`. This allows mise to support a wide variety of tools and languages by leveraging different package managers and their ecosystems.

When you run the [`mise use`](https://mise.jdx.dev/cli/use.html) command, mise will determine the appropriate backend to use based on the tool you are trying to manage. The backend will then handle the installation, configuration, and any other necessary steps to ensure the tool is ready to use.

For more details on how backends fit into mise's overall design, see the [backend architecture documentation](https://mise.jdx.dev/dev-tools/backend_architecture.html).

Below is a list of the available backends in mise:

- [asdf](https://mise.jdx.dev/dev-tools/backends/asdf.html) (provide tools through [plugins](https://mise.jdx.dev/plugins.html))
- [aqua](https://mise.jdx.dev/dev-tools/backends/aqua.html)
- [cargo](https://mise.jdx.dev/dev-tools/backends/cargo.html)
- [conda](https://mise.jdx.dev/dev-tools/backends/conda.html) experimental
- [dotnet](https://mise.jdx.dev/dev-tools/backends/dotnet.html) experimental
- [gem](https://mise.jdx.dev/dev-tools/backends/gem.html)
- [github](https://mise.jdx.dev/dev-tools/backends/github.html)
- [gitlab](https://mise.jdx.dev/dev-tools/backends/gitlab.html)
- [go](https://mise.jdx.dev/dev-tools/backends/go.html)
- [http](https://mise.jdx.dev/dev-tools/backends/http.html)
- [npm](https://mise.jdx.dev/dev-tools/backends/npm.html)
- [pipx](https://mise.jdx.dev/dev-tools/backends/pipx.html)
- [spm](https://mise.jdx.dev/dev-tools/backends/spm.html) experimental
- [ubi](https://mise.jdx.dev/dev-tools/backends/ubi.html)
- [vfox](https://mise.jdx.dev/dev-tools/backends/vfox.html) (provide tools through [plugins](https://mise.jdx.dev/plugins.html))
- [custom backends](https://mise.jdx.dev/backend-plugin-development.html) (build your own backend with a plugin which itself provides many tools)