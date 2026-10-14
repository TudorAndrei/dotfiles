# Pi configuration

My configuration for the [pi coding agent](https://github.com/earendil-works/pi).

The repo holds the extensions and the global settings only. Sessions, `auth.json`,
the model store and the caches stay in `~/.pi/agent` and are not in git. Skills are
not in this repo; they come from `~/.agents/skills`.

## Layout

| Path | Linked to | Purpose |
|------|-----------|---------|
| `extensions/` | `~/.pi/agent/extensions` | Auto-discovered extensions (`*.ts` and `*/index.ts`) |
| `settings.json` | `~/.pi/agent/settings.json` | Global pi settings: model, provider, theme, packages |

The links come from the `[dotfiles]` section of the dotfiles repository's
`mise.toml`. To make the links again:

```bash
just symlink
```

## Extensions

| Extension | Function |
|-----------|----------|
| `herdr-agent-state.ts` | Reports the agent state to the herdr socket |

`herdr-agent-state.ts` is written by its installer. An update of the herdr
integration writes through the symlink into this repo, which then shows the new
version as a git change.

## Packages

The npm packages in the `packages` list of `settings.json` are installed by pi into
`~/.pi/agent/npm`, which stays out of this repo.
