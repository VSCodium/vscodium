<!-- order: 30 -->

# Other Resources

## Table of Contents

- [What are reh and reh-web components?](#reh)

## <a id="reh"></a>What are reh and reh-web components?

These are components related to accessing VSCodium in different environments:

- **Remote Host (`reh`)**: This is a server-side component that enables VSCodium's remote development capabilities. When you connect to a remote machine using SSH or WSL (Windows Subsystem for Linux), the `reh` component runs on the remote host, allowing VSCodium to operate as if it were running locally on that machine.

- **Web Host (`reh-web`)**: This is a server-side component associated with the `codium serve-web` command. Executing `codium serve-web` starts a local web server that hosts a browser-accessible version of VSCodium. This allows you to use the VSCodium interface and functionality through a web browser, for instance, on a tablet or a different machine on your local network.
