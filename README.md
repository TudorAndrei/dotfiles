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
4. In tmux, press `C-Space I` to install the tmux plugins

## Nix: Ubuntu/WSL and the homelab laptop

Both machines use this repository at `~/dotfiles`:

| Path | Machine and role |
|------|------------------|
| `nix/flake.nix`, `nix/home.nix`, `nix/packages.nix` | Ubuntu/WSL management machine: Lix, Home Manager and NH |
| `nix/hosts/nixos-laptop/` | Headless NixOS/Lix runtime host: Incus containers and VMs, Tailscale and SSH |

The flakes have separate lock files: the management environment uses
`nixos-unstable`, while the laptop uses `nixos-26.05`.

Apply the management machine's packages and environment:

```bash
nh home switch --configuration tudor "path:$HOME/dotfiles/nix"
# Once just is available:
just nix-home
```

Home Manager links `~/.config/herdr/config.toml` to
`~/dotfiles/configs/herdr/config.toml` with `mkOutOfStoreSymlink`. Edit the
repository file directly, then run `herdr server reload-config` to apply
changes to a running session. Herdr's runtime files remain in its config
directory.

The same Home Manager activation installs the plugins listed in
`configs/herdr/plugins.txt` and links the Navigator and automatic-rename
settings from `configs/herdr/plugins/`. `just herdr-plugins` installs missing
plugins; `bash configs/herdr/install-plugins.sh --update` updates existing
plugin versions too. Nix provides the Rust build tools and plugin runtime
dependencies; plugin checkouts and compiled binaries stay in Herdr's runtime
directory.

Build and deploy the laptop configuration from the management machine:

```bash
~/dotfiles/nix/hosts/nixos-laptop/deploy
# Or:
just nixos-laptop
```

The deployment script builds locally, copies the system closure over SSH,
updates the laptop's configuration files, and activates the system. On the
laptop, `/etc/nixos` links to
`/home/tudor/dotfiles/nix/hosts/nixos-laptop`.

`configs/ssh/config` contains the laptop's LAN and Tailscale aliases. Each
management machine needs its own authorized key at `~/.ssh/nixos-laptop`.
Keep GitHub identity settings in the included `~/.ssh/config.local`; origin
on the management machine uses `git@github.com:TudorAndrei/dotfiles.git`.

The laptop currently uses Wi-Fi. NetworkManager prefers Ethernet when a
wired link is available. Incus owns the `default` LVM volume group on the
remaining NVMe partition; its containers and VMs use `10.77.0.0/24` behind
NAT. Lid-close events are ignored, sleep is disabled, and a timer requests
a clean shutdown at 5% battery while discharging.

Wi-Fi credentials, SSH private keys, account passwords and Tailscale state
stay on their respective machines. Local `.nh-backup.*` directories are
ignored. Off-machine backups still need a destination.

### Laptop NVIDIA and power policy

The MSI Raider GE66 12UGS has an i7-12700H, 16 GiB RAM and an RTX 3070 Ti
Laptop GPU (`0000:01:00.0`). Its pinned `nixos-hardware` input supplies the
matching Intel CPU, laptop, SSD and NVIDIA Ampere modules. There is no exact
Raider GE66 module; profiles for other MSI models are not imported.

`nvidia.nix` selects NVIDIA's production driver and open kernel modules.
The host remains headless. DRM is available to Incus while NVIDIA's console
framebuffer and persistence daemon are disabled, allowing runtime D3 when
the GPU is unused. The optional `nvidia` profile adds the NVIDIA device and
injects its compute, utility and video libraries into a container:

```bash
incus launch images:ubuntu/noble gpu-example -p default -p nvidia
incus exec gpu-example -- nvidia-smi
```

The default profile does not attach a GPU. This configuration supports
container GPU sharing; whole-device VM passthrough requires a separate VFIO
configuration. No CUDA toolkit is installed on the host; applications supply
their matching toolkit/runtime inside their containers.

`power.nix` uses TLP with Intel HWP scaling and balanced EPP on AC. On battery
it prioritizes efficiency and disables CPU turbo to extend outage runtime.
Thermald manages CPU thermals using the platform's policy. Wi-Fi power saving
stays off on both power sources because this is the administration link.
Sleep remains disabled. LVM monitoring and SMART monitoring are enabled;
background Nix builds have limited parallelism and lower CPU/I/O weight.

Querying `nvidia-smi` wakes the GPU. To check idle suspend without waking it,
read `/sys/bus/pci/devices/0000:01:00.0/power/runtime_status` after stopping
GPU workloads. `/proc/driver/nvidia/gpus/0000:01:00.0/power` reports RTD3
and video-memory status.

Sources: [nixos-hardware](https://github.com/NixOS/nixos-hardware/blob/master/README.md),
[NVIDIA open modules](https://download.nvidia.com/XFree86/Linux-x86_64/595.71.05/README/kernel_open.html),
[NVIDIA RTD3](https://download.nvidia.com/XFree86/Linux-x86_64/595.71.05/README/dynamicpowermanagement.html),
[Intel pstate](https://www.kernel.org/doc/html/latest/admin-guide/pm/intel_pstate.html),
[TLP processor policy](https://linrunner.de/tlp/settings/processor.html),
[Incus GPU devices](https://linuxcontainers.org/incus/docs/main/reference/devices_gpu/).

For a fresh laptop installation, create the EFI and root filesystems with
the labels in `hardware-configuration.nix`, then initialize its dedicated
Incus partition as the `default` LVM volume group before applying the
Incus preseed. The configuration expects that existing group.

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
