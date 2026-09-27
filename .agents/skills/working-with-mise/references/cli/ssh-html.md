mise ssh

ssh` [​](#mise-ssh)

- **Usage:** `mise ssh [FLAGS] [DESTINATION] [COMMAND]…`
- **Source code:** [`src/cli/ssh.rs`](https://github.com/jdx/mise/blob/main/src/cli/ssh.rs)

Open an SSH session, optionally borrowing read-only GitHub access

## Arguments [​](#arguments)

- **`[DESTINATION]`** — OpenSSH destination or SSH-config alias
- **`[COMMAND]…`** — Command to execute after --; omit for an interactive shell

## Flags [​](#flags)

- **`-i --identity-file <IDENTITY_FILE>`** — SSH identity file
- **`-p --port <PORT>`** — SSH port
- **`-o --ssh-option <SSH_OPTION>`** — OpenSSH option; repeat for multiple options
- **`--github-relay-read-only`** — Borrow read-only GitHub access for this session only
- **`--github-relay-repo <OWNER/REPO>`** — Approved GitHub repository; repeat to authorize more repositories
- **`--github-relay-all-repos`** — Explicitly authorize reads of all repositories accessible locally
- **`--github-relay-log-requests`** — Log sanitized relay requests on local stderr
- **`--github-relay-no-log-requests`** — Disable request logging, overriding the saved preference
- **`--github-relay-log-format <FORMAT>`** — Relay log and summary format: text or jsonl
- **`--github-relay-max-duration <DURATION>`** — Expire borrowed access after a duration such as 1h (0s: session lifetime)
- **`-h --help`** — Print help

## Related documentation [​](#related-documentation)

- [Git provider authentication](https://mise.jdx.dev/dev-tools/github-tokens.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/ssh.md)

Last updated:

Pager

[Previous pagemise sponsors](https://mise.jdx.dev/cli/sponsors.html)

[Next pagemise sync](https://mise.jdx.dev/cli/sync.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)