# AGENTS.md - Dotfiles Repository

## Configuration

Configuration for programs defined in these dotfiles should only be edited here not in the symlink location!

## Overview

This is a dotfiles repository containing configuration files for various tools:

- **Neovim** (LazyVim-based) - `nvim/` directory
- **Pi coding agent** - `pi/` directory (submodule; extensions and global settings)
- **Zsh** - `configs/zsh/`
- **Tmux** - `.tmux.conf` and `configs/tmux/`
- **Herdr** - `configs/herdr/` (agent multiplexer, mirrors the tmux keymap)
- **Hyprland** - `configs/hypr/`
- **Alacritty** - `configs/alacritty/`
- **Starship** - `starship.toml`
- Various other tools (Alacritty, Rofi, Waybar, etc.)

## Build/Lint/Test Commands

### General

```bash
# Create config directories and symlinks
just symlink

# Preview what would change first
mise bootstrap --only files,dotfiles --dry-run
mise dot status

# Install system packages
just install
mise bootstrap packages status
```

### Shell Scripts

```bash
# Shellcheck for shell script linting
shellcheck scripts/macos/install.sh scripts/debian/install.sh

# Bash syntax check
bash -n scripts/bootstrap.sh
```

## Code Style Guidelines

### Shell Scripts

- **Shebang**: `#!/usr/bin/env bash` or `#!/bin/bash`
- **Shell**: Use bash, not sh
- **Error handling**: Use `set -e` at the top
- **Variables**: Use `UPPER_SNAKE_CASE` for environment variables, lowercase for local vars
- **Quotes**: Use double quotes for strings with variables, single quotes for literals
- **Functions**: Define with `function_name() { ... }` or `function function_name { ... }`
- **Exit codes**: Explicitly exit with codes (0 for success, 1 for error)

### General Config Files

- **YAML**: Use 2-space indentation
- **TOML**: Follow standard TOML conventions
- **JSON**: Standard JSON formatting

## Key Files and Locations

| Path | Purpose |
|------|---------|
| `configs/zsh/` | Zsh configuration |
| `configs/hypr/` | Hyprland window manager config |
| `configs/tmux/` | Tmux configuration |
| `configs/herdr/config.toml` | Herdr configuration (linked as a single file; the config dir holds runtime sockets) |
| `configs/herdr/plugins.txt` | Herdr plugin list, one `owner/repo` per line |
| `configs/herdr/plugins/<id>.toml` | Per-plugin config, linked to `~/.config/herdr/plugins/config/<id>/config.toml` |
| `configs/herdr/install-plugins.sh` | Installs everything in `plugins.txt` (`just herdr-plugins`) |
| `configs/herdr/tmux-resurrect-import.py` | Converts a tmux-resurrect save into a herdr-resurrect snapshot |
| `pi/extensions/` | Pi extensions, linked to `~/.pi/agent/extensions` |
| `pi/settings.json` | Pi global settings, linked to `~/.pi/agent/settings.json` (sessions, auth and caches stay in `~/.pi/agent`) |
| `mise.toml` | `[dotfiles]` symlinks, `[bootstrap.directories]`, `[bootstrap.repos]`, `[bootstrap.packages]`, `[bootstrap.hooks]` |
| `[bootstrap.hooks].post-packages` | Runs `scripts/macos/install.sh` or `scripts/debian/install.sh` by platform |
| `scripts/macos/Brewfile` | Only tap packages that mise cannot evaluate (`menuanywhere`, `netbird-ui`, `neardrop`, `muzik`); everything else is in `mise.toml` |

## Important Neovim Settings

- Leader key: `,` (comma)
- Local leader: `,` (comma)
- Tab size: 4 spaces
- LazyVim picker: snacks

## Common Tasks

### Adding a New Config

1. Add config file to appropriate directory in `configs/`
2. Add a `[dotfiles]` entry in `mise.toml`
3. Run `just symlink` to create the symlink

Use `variants = [{ os = "macos" }]` or `variants = [{ os = "linux" }]` for an
entry that belongs to one platform only. Use `mode = "symlink-each"` when the
target directory also holds files mise must leave alone.
