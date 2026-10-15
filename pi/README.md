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

## Home CLIProxyAPI

The `@router-for-me/pi-cliproxyapi-provider` package in `settings.json` connects
Pi to CLIProxyAPI on the NixOS laptop. It discovers the available models and
stores the URL and client key in `~/.pi/agent/cliproxyapi.json`. This file is
local to the machine and must not go in git.

Before the first login, create the file with private permissions:

```bash
if [ ! -e ~/.pi/agent/cliproxyapi.json ]; then
  install -m 600 /dev/null ~/.pi/agent/cliproxyapi.json
  printf '{}\n' > ~/.pi/agent/cliproxyapi.json
fi
chmod 600 ~/.pi/agent/cliproxyapi.json
```

Then start Pi and run `/login cliproxyapi`. Enter
`https://nixos-laptop.tail582219.ts.net:8445` as the base URL. Enter the
client key from `access.api-keys` in the guest's `/srv/cliproxy/config.yaml`.
Pi saves both values in the local file. It also saves the credential in its
local `auth.json` file. Select a `cliproxyapi` model with `/model`.

The package needs the proxy's `/backend-api` path for inference. The laptop's
public `https://casapuiu.home.ro/llm/v1` route does not provide this path, so
use the Tailscale URL above. Run `/cliproxyapi-refresh` after you add models
to the proxy.

## Packages

The npm packages in the `packages` list of `settings.json` are installed by pi into
`~/.pi/agent/npm`, which stays out of this repo.
