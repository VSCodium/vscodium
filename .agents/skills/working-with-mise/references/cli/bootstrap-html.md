mise bootstrap

bootstrap` [​](#mise-bootstrap)

- **Usage:** `mise bootstrap [FLAGS] [SUBCOMMAND]`
- **Aliases:** `bs`
- **Effect:** destructive — may delete or irreversibly overwrite
- **Source code:** [`src/cli/bootstrap.rs`](https://github.com/jdx/mise/blob/main/src/cli/bootstrap.rs)

Set up a machine from the current configuration

Runs these phases in order, when configured and selected:

1. Linux accounts, then package-manager plugins.
2. Pre-packages files/directories, the pre-packages hook, then packages handled by built-in managers.
3. Privileged files/directories, system and user services, firewall, and Compose projects.
4. Git repositories, then dotfiles, each with its pre/post hooks.
5. Shell activation, macOS defaults and LaunchAgents, Linux user units, and user settings.
6. The pre-tools hook, versioned tools, and post-tools hook.
7. Package-plugin packages, then the post-packages hook and services requiring tools.
8. The `bootstrap` task, when defined, then the final hook.

Defaults and user settings also have pre/post hooks. See <https://mise.jdx.dev/bootstrap.html> for the complete phase order and configuration. Unchanged resource state is skipped, but hooks and the bootstrap task can run again; make those commands safe to repeat. Dotfile templates may execute while checking state.

Use `--dry-run` to preview the selected workflow, `bootstrap status` to inspect state, or `bootstrap plan` for the declarative-resource plan. `--only` and `--skip` accept repeated or comma-separated parts and cannot be combined.

## Flags [​](#flags)

- **`--from <GIT_URL>`** — Clone a git repository and bootstrap from its configuration
- **`--adopt <GIT_URL|OWNER/REPO>`** — Adopt global configuration or shared dotfile history from a Git repository, then bootstrap
- **`--replace-history`** — Replace local dotfile history while adopting a setup repository
- **`--from-dir <DIR>`** — Directory used for the repository cloned by --from
- **`-n --dry-run`** — Print what would happen without installing anything
- **`-y --yes`** — Skip confirmation prompts
- **`--skip-dirty`** — Skip configured repos with local changes instead of failing
- **`--force-dotfiles`** — Overwrite existing files that conflict with whole-file dotfile entries
- **`--only <ONLY>`** — Run only one or more bootstrap parts

  Can be passed multiple times or as a comma-separated list. Cannot be used with `--skip`.

  **Choices:** `plugins`, `packages`, `accounts`, `files`, `services`, `firewall`, `compose`, `repos`, `dotfiles`, `mise-shell-activate`, `macos-defaults`, `macos-launchd-agents`, `linux-systemd-units`, `user`, `tools`, `task`, `final-hook`, `shell`, `defaults`, `launchd`, `systemd`
- **`--prompt-secrets`** — Prompt securely for missing bootstrap secret inputs
- **`--skip <SKIP>`** — Skip one or more bootstrap parts

  Can be passed multiple times or as a comma-separated list.

  **Choices:** `plugins`, `packages`, `accounts`, `files`, `services`, `firewall`, `compose`, `repos`, `dotfiles`, `mise-shell-activate`, `macos-defaults`, `macos-launchd-agents`, `linux-systemd-units`, `user`, `tools`, `task`, `final-hook`, `shell`, `defaults`, `launchd`, `systemd`
- **`--update`** — Refresh package manager metadata and update configured repos
- **`-h --help`** — Print help

## Examples [​](#examples)

```
mise bootstrap                    # packages + repos + dotfiles + tools + bootstrap task
mise -E work bootstrap --from git@github.com:example/dotfiles.git --yes
mise bootstrap --adopt git@github.com:example/mise-config.git --yes
mise bootstrap --adopt git@github.com:example/mise-config.git --replace-history --yes
mise bootstrap --force-dotfiles   # replace conflicting dotfile targets
mise bootstrap --skip tools,task  # skip tool installation and the bootstrap task
mise bootstrap --only tools       # run just tool installation
mise bootstrap status --missing
mise bootstrap packages apply --yes
mise bootstrap repos status
mise bootstrap repos apply --dry-run
mise dot status
mise bootstrap mise-shell-activate apply --dry-run
mise bootstrap macos defaults status
mise bootstrap macos launchd-agents apply --dry-run
mise bootstrap linux systemd-units apply --dry-run
mise bootstrap user apply --dry-run
```

## Subcommands [​](#subcommands)

- [`mise bootstrap accounts <SUBCOMMAND>`](https://mise.jdx.dev/cli/bootstrap/accounts.html)
- [`mise bootstrap compose <SUBCOMMAND>`](https://mise.jdx.dev/cli/bootstrap/compose.html)
- [`mise bootstrap dotfiles <SUBCOMMAND>`](https://mise.jdx.dev/cli/bootstrap/dotfiles.html)
- [`mise bootstrap files <SUBCOMMAND>`](https://mise.jdx.dev/cli/bootstrap/files.html)
- [`mise bootstrap firewall <SUBCOMMAND>`](https://mise.jdx.dev/cli/bootstrap/firewall.html)
- [`mise bootstrap linux <SUBCOMMAND>`](https://mise.jdx.dev/cli/bootstrap/linux.html)
- [`mise bootstrap macos <SUBCOMMAND>`](https://mise.jdx.dev/cli/bootstrap/macos.html)
- [`mise bootstrap mise-shell-activate <SUBCOMMAND>`](https://mise.jdx.dev/cli/bootstrap/mise-shell-activate.html)
- [`mise bootstrap packages <SUBCOMMAND>`](https://mise.jdx.dev/cli/bootstrap/packages.html)
- [`mise bootstrap plan [FLAGS]`](https://mise.jdx.dev/cli/bootstrap/plan.html)
- [`mise bootstrap plugins <SUBCOMMAND>`](https://mise.jdx.dev/cli/bootstrap/plugins.html)
- [`mise bootstrap remote [FLAGS] [TARGET]…`](https://mise.jdx.dev/cli/bootstrap/remote.html)
- [`mise bootstrap repos <SUBCOMMAND>`](https://mise.jdx.dev/cli/bootstrap/repos.html)
- [`mise bootstrap secrets <SUBCOMMAND>`](https://mise.jdx.dev/cli/bootstrap/secrets.html)
- [`mise bootstrap services <SUBCOMMAND>`](https://mise.jdx.dev/cli/bootstrap/services.html)
- [`mise bootstrap status [FLAGS]`](https://mise.jdx.dev/cli/bootstrap/status.html)
- [`mise bootstrap user <SUBCOMMAND>`](https://mise.jdx.dev/cli/bootstrap/user.html)

## Related documentation [​](#related-documentation)

- [Bootstrap workflow](https://mise.jdx.dev/bootstrap.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/bootstrap.md)

Last updated:

Pager

[Previous pagemise bin-paths](https://mise.jdx.dev/cli/bin-paths.html)

[Next pagemise bootstrap accounts](https://mise.jdx.dev/cli/bootstrap/accounts.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)