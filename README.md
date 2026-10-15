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

One flake at `nix/flake.nix` and one lock file manage both machines:

- `homeConfigurations."tudor@parnaie"`: Ubuntu/WSL desktop Home Manager environment.
- `nixosConfigurations.nixos-laptop`: full laptop NixOS system.
- `packages.x86_64-linux`: management packages and NH.

The desktop uses the pinned `nixpkgs` unstable input; the laptop uses the
pinned `nixpkgs-stable` 26.05 input. Home Manager follows the desktop input
and nixos-hardware follows the laptop input. Both NH flake variables point
to `~/dotfiles/nix`. The older Home Manager output name `tudor` remains an
alias for compatibility.

Apply the management machine's packages and environment:

```bash
nh home switch --configuration "tudor@parnaie" "path:$HOME/dotfiles/nix"
# Once just is available:
just nix-home
```

The WSL desktop has 64 GiB RAM, 20 logical CPUs and an RTX 3080 (10 GiB).
`just wsl-optimize` copies `configs/wsl/wslconfig` to the Windows user's
`.wslconfig` and applies the root-owned Ubuntu Lix settings using WSL's
root-user interoperability. Existing Windows configuration is backed up
before replacement; edit the repository template to retain custom settings.
These machine-specific system files use an explicit installer rather than
mise's user-config symlinks.

Lix allows two concurrent builds with eight threads each, instead of twenty
builds each requesting twenty threads. Its daemon has lower CPU and I/O
weight under contention. Unrooted store paths can be collected when free
space falls below 2 GiB, targeting 8 GiB free; rooted generations remain.
The client and daemon both load `nix/nix.custom.conf` (the daemon receives
a root-owned copy). Reapply with `just wsl-optimize` after changing it.

WSL retains a 32 GiB memory ceiling, all 20 CPUs and 8 GiB swap. Gradual
idle cache reclamation balances Windows memory recovery with warm Linux
build caches. Lix changes take effect immediately; Windows WSL changes
require saving work, running `wsl --shutdown` in Windows, and reopening
Ubuntu. This terminates every WSL session, including Herdr.

Keep build trees and `/nix` on the Linux filesystem, as this checkout
already does. GPU access uses the Windows NVIDIA driver through WSL:
`/usr/lib/wsl/lib/nvidia-smi` works, and a CUDA driver API kernel test on
the RTX 3080 returned `41 + 1 = 42`. CPU power management and GPU display
drivers belong to Windows; bare-metal laptop power services are not applied
inside this VM. Nix-built GPU applications may need their own runtime
library integration; the CUDA check validates the Ubuntu driver bridge.

Sources: [Microsoft WSL configuration](https://learn.microsoft.com/en-us/windows/wsl/wsl-config),
[Lix build concurrency](https://docs.lix.systems/manual/lix/stable/advanced-topics/cores-vs-jobs.html),
[NVIDIA CUDA on WSL](https://docs.nvidia.com/cuda/wsl-user-guide/index.html).

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
```

The deployment script builds locally, copies the system closure over SSH,
updates the laptop's configuration files, and activates the system. On the
laptop, `/etc/nixos` links to
`/home/tudor/dotfiles/nix`.

`configs/ssh/config` contains the laptop's LAN and Tailscale aliases. Each
management machine needs its own authorized key at `~/.ssh/nixos-laptop`.
Keep GitHub identity settings in the included `~/.ssh/config.local`; origin
on the management machine uses `git@github.com:TudorAndrei/dotfiles.git`.

The laptop currently uses Wi-Fi. NetworkManager prefers Ethernet when a
wired link is available. Its existing `CasaPuiu` connection is pinned to
5 GHz on the host with `nmcli connection modify CasaPuiu 802-11-wireless.band a`;
this saved NetworkManager profile setting is not managed by the NixOS flake.
The AX1675i connects with Wi-Fi 6 at 160 MHz; it does not support Wi-Fi 7 MLO.
SSH accepts the declared `parnaie` and `piticu.local` public keys for `tudor`;
password authentication is disabled. Use `IdentitiesOnly=yes` and an explicit
private key if an SSH agent offers too many identities.
Incus owns the `default` LVM volume group on the
remaining NVMe partition; its containers and VMs use `10.77.0.0/24` behind
NAT. Lid-close events are ignored, sleep is disabled, and a timer requests
a clean shutdown at 5% battery while discharging.

Wi-Fi credentials, SSH private keys, account passwords and Tailscale state
stay on their respective machines. Local `.nh-backup.*` directories are
ignored. Off-machine backups still need a destination.

### Immich on the laptop

Immich runs as a NixOS service with the package from the pinned unstable
Nixpkgs input and local PostgreSQL and Redis. Its photo library uses a
separate 200 GiB ext4 thin volume in the existing `default`
LVM pool. The Incus `media-data` volume remains with the media container.
The database stays on the laptop's local root filesystem. This arrangement
does not add another container to the 16 GiB host.

Create the volume once, on the laptop, before the first deployment:

```bash
ssh nixos-laptop 'sudo bash -s' < nix/hosts/nixos-laptop/prepare-immich-storage
nix/hosts/nixos-laptop/deploy
```

The storage script creates the volume and formats it only when it does not
exist. The NixOS mount uses `nofail` so a missing volume does not stop boot.
Immich refuses to start unless `/var/lib/immich` is mounted; uploads cannot
fill the 100 GiB root filesystem by mistake.

Open `http://100.121.29.45:2283/` from a Tailscale device to create the first
Immich account. Immich listens on `0.0.0.0:2283` and does not use Tailscale
Serve. The host firewall does not open port 2283 on LAN or public interfaces,
and the public Caddy site has no Immich route. The Tailscale connection
encrypts traffic between devices. Tailscale ACLs control which tailnet
members can reach the laptop.

Back up both `/var/lib/immich` and the local PostgreSQL database. Immich's
database dumps in the library do not include the original photos. The thin
pool is shared with Incus, so monitor its physical use with
`sudo lvs -o lv_name,lv_size,data_percent default/IncusThinPool`.

### Laptop dashboard

Homepage runs as a NixOS service on `nixos-laptop`. Open
`https://nixos-laptop.tail582219.ts.net:8446/` from a Tailscale device.
The page has links and availability checks for Immich, Seedstrem, Prowlarr,
qBittorrent and CLIProxyAPI. Its header shows host CPU, RAM, uptime, root
disk and Immich disk use. A system card shows Incus thin pool use. The pool
value comes from a read-only endpoint on host loopback. Homepage and that
endpoint do not use the public Caddy site.

After the NixOS deployment, add the private HTTPS route once:

```bash
ssh nixos-laptop 'sudo tailscale serve --bg --https=8446 http://127.0.0.1:8083'
```

Homepage configuration lives in `nix/hosts/nixos-laptop/homepage.nix`. Its
service checks use host loopback addresses, so they do not need API keys or
Docker socket access. The disk widgets show the host root and Immich mounts;
the thin pool widget reports the shared LVM pool that backs Incus storage.

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

The profile also mounts Nixpkgs' unmodified `nvidia-smi` binary read-only.
It targets glibc-based guests such as Ubuntu/Debian, whose loader can run
that binary without needing the host's Nix store.

For kernel or GPU-driver changes, stage the system for the next boot with
`~/dotfiles/nix/hosts/nixos-laptop/deploy boot`, then reboot the laptop.
This avoids loading a new NVIDIA stack over the currently bound driver.

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

Validated on this laptop with driver 595.71.05: the open kernel driver loaded,
an unprivileged Ubuntu container executed a CUDA/PTX kernel (`41 + 1 = 42`),
`nvidia-smi` worked in the container, and NVENC/NVDEC libraries loaded. After
removing the test container, both NVIDIA PCI functions suspended and video
memory turned off. Idle CPU-package energy samples over 20 seconds were
4.48 W before and 2.34 W after; these are short CPU-only measurements, not
wall-power or sustained-performance benchmarks. No services were failed.

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
  - [starship](https://github.com/starship/starship)

- [Bat](https://github.com/sharkdp/bat)
- [fd](https://github.com/sharkdp/fd)
- [fzf](https://github.com/junegunn/fzf)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fnm](https://github.com/Schniz/fnm#completions)
- [Neovim](https://github.com/TudorAndrei/nvim)
- [Pi config](pi/)

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

## FileList and Stremio on the laptop

`bash scripts/media/deploy.sh` provisions an unprivileged Ubuntu 24.04 Incus
container named `media` on `nixos-laptop`. It runs Docker Compose inside the guest,
using upstream Seedstrem's supported deployment. The NixOS host retains
Incus and its existing GPU/power configuration; no GPU is needed here.
The guest gets four CPUs, 4 GiB RAM, an inherited 30 GiB root disk and a
separate 200 GiB `media-data` volume from the existing LVM pool. Incus
starts the guest at boot, and Docker restarts all three services.

The flow is Stremio → Seedstrem → Prowlarr/FileList for search, then
Seedstrem → qBittorrent-nox for downloading/seeding and HTTP playback.
Torrentio can remain installed alongside it. Searching alone does not
start downloads. Full torrents download for seeding; a 50 GiB release
filter and an 80% media-volume usage gate bound new downloads.

`configs/media/compose.yaml` defines the services;
`configs/media/images.lock.yaml` pins Prowlarr/qBittorrent image digests.
Seedstrem is built from commit
`dd04439e1b3ce0731168feb2b92a2bb66ca94718` in the installer. Its upstream
Dockerfile's build-base tags and guest apt packages are not fully pinned.
Local patches in `configs/media/patches` apply idempotently to that pinned
source. Stream JSON emits only `description`: Stremio aliases `title` to
that field and discards streams when both are present. For private trackers,
discovery retains opaque references and fetches only the selected torrent's
metadata at playback time; private Prowlarr download URLs stay server-side.
The bounded reference registry expires after two hours or a service restart;
reopen the title if a saved stream reference expires. Discovery has an
eight-second search budget and a one-hour cache. Patch regression tests run
as part of the image build.
The Python installer generates service passwords, connects both backend
APIs, and initializes Seedstrem settings. Later runs preserve settings
changed in Seedstrem's UI. Prowlarr and qBittorrent use username `admin`.

Retrieve generated passwords locally, without adding them to Git:

```bash
ssh nixos-laptop 'sudo incus exec media -- cat /srv/media/config/credentials.json'
```

Service state, SQLite databases and credentials live under the guest's
`/srv/media/config`; downloads live under `/srv/media/downloads`, both on
`media-data`. These persistent files are not mise-managed symlinks. Back
up this volume/config independently of the Git checkout.

Enable Tailscale **Serve** once in the account, then run
`bash scripts/media/https.sh`.
Stremio devices must connect to your tailnet for this private route.
Public access is described below:

- Seedstrem: `https://nixos-laptop.tail582219.ts.net:9443/`
- Stremio manifest: `https://nixos-laptop.tail582219.ts.net:9443/stremio/manifest.json`
- Prowlarr: `https://nixos-laptop.tail582219.ts.net:8443/`
- qBittorrent: `https://nixos-laptop.tail582219.ts.net:8444/`

Until Serve is enabled, native clients on Tailscale can use
`http://100.121.29.45:8081/stremio/manifest.json`. The host firewall leaves
8081 closed to ordinary LAN/public access while allowing its existing
trusted Tailscale interface. Admin backends bind host localhost; access
them over SSH if HTTPS is not configured:

```bash
ssh -N -L 8081:127.0.0.1:8081 -L 9696:127.0.0.1:9696 -L 8080:127.0.0.1:8080 nixos-laptop
```

Open `http://localhost:9696`, add the **FileList** indexer, enter your
FileList username and passkey, then Test and Save. Prowlarr requires a
passkey, not your normal account password. Enter it in the private UI;
never put it in this public repository. With FileList as the only enabled
indexer, Seedstrem searches it automatically. Then install the manifest
URL in Stremio and test a movie or episode.

Automatic deletion is disabled initially (seed time, target ratio and
abandoned-playback triggers are all zero). Once current FileList/VIP
requirements are confirmed, set a retention policy in Seedstrem Settings.
Eligible removals delete both the torrent and payload; labels must not be
applied to unrelated torrents unless you intend to manage them here.
The 80% limit stops new downloads; it does not evict existing files.
Incoming BitTorrent ports are not forwarded through the home router or
host; outbound connections work, but inbound connectability needs separate
port forwarding if desired.

Validation on deployment: health/manifest responses, Seedstrem's backend
connection tests, private HTTPS/manifest, the Prowlarr login redirect and an Incus guest restart passed. FileList authentication and a test search passed after credentials were added
(seven streams). Actual media playback still needs client validation.

Sources: [Seedstrem](https://github.com/kipsilabs/seedstrem),
[Seedstrem configuration](https://github.com/kipsilabs/seedstrem/blob/main/config.example.yaml),
[Prowlarr FileList integration](https://github.com/Prowlarr/Prowlarr/tree/develop/src/NzbDrone.Core/Indexers/Definitions/FileList),
[Docker inside Incus](https://linuxcontainers.org/incus/docs/main/faq/#how-can-i-run-docker-inside-an-incus-container).

### CLIProxyAPI on the laptop

`bash scripts/cliproxy/deploy.sh` creates an Incus guest named `cliproxy`
and runs CLIProxyAPI in Docker. Caddy sends `https://casapuiu.home.ro/llm/v1/*` to
the guest. The guest and laptop listen on loopback only. The first deployment
creates a random client key in `/srv/cliproxy/config.yaml` inside the guest.
The management dashboard uses a separate key. Keep both keys and the OAuth
files private.
Session affinity keeps each Codex session on one OAuth account when more
accounts are added. If that account becomes unavailable, CLIProxyAPI can
select another account.

Deploy the laptop NixOS configuration, then the guest:

```bash
nix/hosts/nixos-laptop/deploy
bash scripts/cliproxy/deploy.sh
```

Read the client key from `access.api-keys` in the guest config:

```bash
ssh nixos-laptop 'sudo incus exec cliproxy -- cat /srv/cliproxy/config.yaml'
```

From a device on the tailnet, open
`https://nixos-laptop.tail582219.ts.net:8445/management.html`. Read the
management key and enter it in the dashboard:

```bash
ssh nixos-laptop 'sudo incus exec cliproxy -- cat /srv/cliproxy/management.key'
```

The dashboard can change proxy settings and OAuth files. The public
`/llm` route does not serve it. Tailscale Serve restricts access to the
tailnet, and the dashboard still requires its management key.

To add a Codex account, open a laptop SSH session and run the login tool
in the guest. Keep that session open until login is complete:

```bash
ssh -t nixos-laptop 'sudo incus exec cliproxy -- docker compose -f /opt/cliproxy/compose.yaml run --rm cli-proxy-api ./CLIProxyAPI -codex-login -no-browser'
```

In another Mac terminal, forward the Codex callback port before opening
the login URL printed by the tool:

```bash
ssh -N -L 1455:127.0.0.1:1455 nixos-laptop
```

To add a Claude Code account, run this command in one Mac terminal:

```bash
ssh -t nixos-laptop 'sudo incus exec cliproxy -- docker compose -f /opt/cliproxy/compose.yaml run --rm cli-proxy-api ./CLIProxyAPI -claude-login -no-browser'
```

In another Mac terminal, forward the Claude callback port, then open the
login URL printed by the first command:

```bash
ssh -N -L 54545:127.0.0.1:54545 nixos-laptop
```

For another provider, use its login flag and forward its callback port.
The guest forwards ports 8085, 1455, 54545, 51121, and 11451 to the
laptop loopback for these login flows. OAuth files persist in
`/srv/cliproxy/auths` inside the guest. Check the model list after login:

```bash
curl -H 'Authorization: Bearer <client-key>' https://casapuiu.home.ro/llm/v1/models
```

#### Use the API from another laptop

Install the Codex and Claude Code CLIs on that laptop. Get the client key
from `access.api-keys` as shown above. In a new terminal, enter the key
without saving it in shell history:

```bash
printf 'Client key: '
read -rs CLIPROXY_API_KEY
printf '\n'
export CLIPROXY_API_KEY
curl -fsS -o /dev/null -w '%{http_code}\n' \
  -H "Authorization: Bearer $CLIPROXY_API_KEY" \
  https://casapuiu.home.ro/llm/v1/models
```

The last command must print `200`. Keep the key out of tracked files.
Enter it again in each new terminal, or load it from a local secret store.

For **Codex**, put this profile in `~/.codex/cliproxy.config.toml` on the
client laptop:

```toml
model = "gpt-6-sol"
model_provider = "cliproxy"

[model_providers.cliproxy]
name = "Home CLIProxyAPI"
base_url = "https://casapuiu.home.ro/llm/v1"
env_key = "CLIPROXY_API_KEY"
wire_api = "responses"
requires_openai_auth = false
supports_websockets = false
```

Run `codex --profile cliproxy` from the terminal that has the key. If this
dotfiles repo manages Codex on the client laptop, add the profile to the
repo and link it from there; do not edit a managed symlink.

For **Claude Code**, use the same key in that terminal:

```bash
export ANTHROPIC_BASE_URL=https://casapuiu.home.ro/llm
export ANTHROPIC_AUTH_TOKEN="$CLIPROXY_API_KEY"
claude
```

Run `/status` in Claude Code. It must show the gateway base URL and the
auth token. These shell settings apply only to that terminal.

Sources: [CLIProxyAPI configuration](https://github.com/router-for-me/CLIProxyAPI/blob/main/config.example.yaml),
[Docker layout](https://github.com/router-for-me/CLIProxyAPI/blob/main/docker-compose.yml),
[Codex configuration](https://learn.chatgpt.com/docs/config-file/config-reference),
[Claude Code gateway setup](https://code.claude.com/docs/en/llm-gateway-connect).

### Public streaming without registering client devices

`bash scripts/media/direct.sh` deploys Caddy HTTPS at `casapuiu.home.ro`
and activates that origin for the key-protected streaming gateway. Digi DDNS must track
the router's public WAN address. Reserve `192.168.0.244` for laptop Wi-Fi
MAC `70:1a:b8:22:30:c6`, and forward TCP 80 and 443 to the same internal
ports at that address. Caddy binds this LAN address and obtains/renews its
certificate automatically. Keep both forwarding rules enabled.
Administration stays private on Tailscale ports 9443, 8443 and 8444.
Tailscale DNS acceptance is disabled on this host so router DNS remains
available independently of the tailnet DNS resolver.

A randomly generated 256-bit URL key authenticates addon and playback
requests. The gateway permits only the keyed `/stremio/` and `/dl/` paths;
missing/wrong keys and admin paths return 404. Access logging is disabled
on the gateway, and the rendered key-bearing configuration is stored only
in the guest's root-protected config directory. Requests still reach the
app's normal download limits. The key grants search/playback access, so
treat the entire install URL as a password.

Retrieve the `public_manifest_url` value from the credentials file:

```bash
ssh nixos-laptop 'sudo incus exec media -- cat /srv/media/config/credentials.json'
```

Replace the previous Seedstrem addon with this URL in Stremio. Phones and
TVs can then fetch the addon and streams without Tailscale. Installing the
URL supplies the credential automatically; there is no separate browser
Basic Auth prompt. Seedstrem's private administration remains accessible
at its private tailnet URL on port 9443. Subsequent media deployments preserve the
public gateway and reload it after service changes.

To revoke a leaked URL, stop the public gateway immediately:

```bash
ssh nixos-laptop 'sudo incus exec media -- docker stop media-public-gateway-1'
```

Then replace `public_token` with a freshly generated secret in the guest
credentials file. Run `bash scripts/media/direct.sh` to rerender and reload
the gateway. Reinstall the new manifest on clients. This invalidates the
previous URL credential.
Streaming performance depends on home upload bandwidth and torrent peers.
Sources: [Stremio's key authentication example](https://github.com/Stremio/stremio-addon-with-key),
[Caddy automatic HTTPS](https://caddyserver.com/docs/automatic-https).

Gateway checks passed for missing/wrong keys, blocked administration,
encoded path traversal, keyed manifests and FileList discovery. Returned
playback URLs include the key. A temporary, locally generated 4 KiB torrent
also passed HTTP byte-range streaming (206 with the expected payload and
Content-Range); its torrent, database records and files were removed.

Stremio compatibility validation: the Windows app's own core reports
Backrooms as Ready with nine streams after the JSON alias fix. Cold public
requests returned Backrooms in 0.22 seconds and Shawshank in 1.9 seconds.
Deferred lookup, credential exclusion, registry expiry, single-description
serialization and selected-torrent playback are covered by regression tests.
