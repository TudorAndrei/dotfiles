# dotfiles

## Bootstrap

On a new machine (macOS, Arch-based, or Debian/Ubuntu):

```
bash -c "$(curl -fsSL https://tudorandrei.github.io/bootstrap.sh)"
```

Use this form, not `curl … | bash`. It keeps the terminal on stdin, so the
GitHub login can ask its questions.

The script installs git, clones this repo into `~/dotfiles` over HTTPS (or
updates it), makes `~/.ssh/github` and the `Host github.com` entry in
`~/.ssh/config` if they are absent, runs `gh auth login` when no key
authenticates, switches origin and all submodules to SSH, and then runs
`scripts/bootstrap.sh`. Its source is `bootstrap.sh` in the
`TudorAndrei/tudorandrei.github.io` repo.

`DOTFILES_SKIP_AUTH=1` keeps HTTPS remotes and asks nothing.

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
- [Pi config](https://github.com/TudorAndrei/pi-config)

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

## VPN (macOS)

Twingate and the Tailscale app can run at the same time. Both use split
tunnel: each adds routes only for its own resources or peers, and the
Tailscale app binds its WireGuard sockets to `en0`.

### No internet when Twingate is on

Twingate routes `100.96.0.0/12` into its tunnel and becomes the DNS resolver.
If the router gives CGNAT DNS servers in that range (for example
`100.100.1.1`), Twingate forwards the queries into its own tunnel and names
stop resolving. `ping 1.1.1.1` works, but `dig google.com` times out.

Look at the DHCP DNS servers:

```
ipconfig getpacket en0 | grep domain_name_server
```

Set public DNS servers on Wi-Fi:

```
networksetup -setdnsservers Wi-Fi 1.1.1.1 1.0.0.1 8.8.8.8
```

This applies to every Wi-Fi network. If a captive portal does not open, go
back to the router DNS:

```
networksetup -setdnsservers Wi-Fi empty
```

### Other checks

- If the VPN shows Connected but `tailscale status` says `Tailscale is
  stopped.`, run `tailscale up`. Until then, `100.x` addresses go to `en0`.
- If Twingate names stop resolving while Tailscale is on, turn off **Use
  Tailscale DNS settings** in the Tailscale app.
- Tailscale also uses `100.64.0.0/10`, which contains the Twingate range. A
  conflict occurs only if a Twingate resource gets the same IP as a Tailscale
  peer.
- Do not use a VPN exit node (`0.0.0.0/0`) together with a Tailscale client in
  a container. The container's WireGuard packets go into the exit node tunnel,
  and large packets are lost.

## Firefox

```
Enable `toolkit.legacyUserProfileCustomizations.stylesheets` in `about:config`
add userChrome.css
```

# Docker

`λ sudo systemctl enable --now docker`

`λ sudo usermod -aG docker $USER`
