mise skills

skills` [​](#mise-skills)

- **Usage:** `mise skills [SUBCOMMAND]`
- **Aliases:** `skill`
- **Effect:** read-only
- **Source code:** [`src/cli/skills/mod.rs`](https://github.com/jdx/mise/blob/main/src/cli/skills/mod.rs)

Agent skills the active tools ship, from their packslips

A tool installed with the `packslip:` backend may declare an agent skill: a directory holding `SKILL.md` and whatever it references, in the Agent Skills format. mise knows which version of each tool is active here, so it can hand an agent the skill for exactly that version.

## Flags [​](#flags)

- **`-h --help`** — Print help

## Subcommands [​](#subcommands)

- [`mise skills ls [-J --json]`](https://mise.jdx.dev/cli/skills/ls.html)
- [`mise skills sync [FLAGS]`](https://mise.jdx.dev/cli/skills/sync.html)

## Related documentation [​](#related-documentation)

- [Skills and other Packslip resources](https://mise.jdx.dev/dev-tools/packslip-resources.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/skills.md)

Last updated:

Pager

[Previous pagemise shell-alias unset](https://mise.jdx.dev/cli/shell-alias/unset.html)

[Next pagemise skills ls](https://mise.jdx.dev/cli/skills/ls.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)