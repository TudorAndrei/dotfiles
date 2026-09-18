# dotfiles

## Bootstrap

On a new machine (macOS, Arch-based, or Debian/Ubuntu):

```
curl -fsSL https://tudorandrei.github.io/bootstrap.sh | bash
```

That script installs git if necessary, clones this repo into `~/dotfiles` (or
updates it), and then runs `scripts/bootstrap.sh`. Its source is `bootstrap.sh`
in the `TudorAndrei/tudorandrei.github.io` repo.

To do the same steps manually:

```
git clone --recurse-submodules https://github.com/TudorAndrei/dotfiles.git ~/dotfiles
bash ~/dotfiles/scripts/bootstrap.sh
```

`scripts/bootstrap.sh` installs mise and just, then runs `just bootstrap`:
submodules, symlinks, packages, macOS defaults, services, nvim plugins and
herdr plugins.

### Machine-local files

These files hold identities or credentials, so this repo does not track them.
Create them on each machine:

| Path | Content |
|------|---------|
| `~/.npmrc` | `//registry.npmjs.org/:_authToken=<token>` |
| `~/.gitconfig-work` | `[user]` name and email for `~/work/` repos |

mise applies the packages, the symlinks and the macOS defaults from
`mise.toml`. To look before you change anything:

```
mise bootstrap status
mise bootstrap --dry-run
mise dot status
```

`just symlink` stops if a target is a real file instead of a link. Inspect
the named paths, then run `just symlink-force` to replace them.

### CachyOS

After the first bootstrap:

1. Log out and log back in (or restart)
2. Start Hyprland from SDDM
3. Set up openrazer-daemon: `sudo gpasswd -a $USER plugdev`
4. Install Spotify, then run `spicetify apply`
5. In tmux, press `C-Space I` to install the tmux plugins

## Packages

## Asus

<https://asus-linux.org/guides/arch-guide/>

### Terminal

- [alacritty](https://github.com/alacritty/alacritty)
- [Zsh](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH)
  - [zimfw](https://github.com/zimfw/zimfw)
    - environment
    - git
    - archive
    - utility
    - fzf
    - duration-info
    - rimraf/k
    - agkozak/zsh-z
    - zsh-user/zsh-syntax-highlighting
    - zsh-user/zsh-history-substring-search
    - zsh-users/zsh-completions
  - [starship](https://github.com/starship/starship)

- [Bat](https://github.com/sharkdp/bat)
- [fd](https://github.com/sharkdp/fd)
- [fzf](https://github.com/junegunn/fzf)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fnm](https://github.com/Schniz/fnm#completions)
- [Neovim](https://github.com/TudorAndrei/nvim)

### Window manager

- arandr
- i3
  - i3-blocks
- blueman
- nmapplet

### Font

- Nerd hack Font

### Keyboard

```
echo "options hid_apple fnmode=0" | sudo tee -a /etc/modprobe.d/hid_apple.conf
```

## Firefox

```
Enable `toolkit.legacyUserProfileCustomizations.stylesheets` in `about:config`
add userChrome.css
```

# Docker

`λ sudo systemctl enable --now docker`

`λ sudo usermod -aG docker $USER`
