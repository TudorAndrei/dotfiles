# LG TV (webOS)

## Device

| Item | Value |
| --- | --- |
| Model | LG 43UP75003LF (2021) |
| webOS | 6 (board `lm21a`, ARM `armv7l`) |
| RAM / storage | 1.5 GB / 8 GB |
| Address | `192.168.0.186` |
| ares device name | `lg-tv` |

The TV is in Developer Mode. It is not rooted.

## Installed apps

| App | ID | Source |
| --- | --- | --- |
| Homebrew Channel | `org.webosbrew.hbchannel` | [webosbrew/webos-homebrew-channel](https://github.com/webosbrew/webos-homebrew-channel) |
| Origin (Better Stremio fork) | `tv.stremioorigin.app` | [betterstremio/origin](https://github.com/betterstremio/origin) |

Homebrew Channel repository for Origin:
`https://betterstremio.github.io/webos/apps.json`.
Add it in Homebrew Channel at **Settings → Add repository**.

## Developer Mode session

The Developer Mode session expires. When it expires, the TV removes all
developer apps. To keep the apps, open the Developer Mode app on the TV and
extend the session before it expires.

## Tools

`mise` installs [ares-cli-rs](https://github.com/webosbrew/ares-cli-rs)
(`github:webosbrew/ares-cli-rs` in `configs/mise/config.toml`).

The device config is in `~/.webos/ose/novacom-devices.json`. The SSH key is
`~/.ssh/webos_<id>`. The key passphrase is in the device config.

```sh
ares-device -D                              # list devices
ares-install -d lg-tv app.ipk               # install an app
ares-install -d lg-tv -l                    # list installed apps
ares-install -d lg-tv -r tv.stremioorigin.app   # remove an app
ares-launch -d lg-tv org.webosbrew.hbchannel     # start an app
ares-shell -d lg-tv -r 'uname -m'           # run a command
```

## Known problem: "No route to host" on macOS

On macOS, the `ares-*` tools can fail with
`Failed to connect: No route to host`, but `nc -z 192.168.0.186 9922`
connects. The probable cause is the macOS Local Network permission for these
binaries. Use plain SSH instead:

```sh
# Make a temporary key copy without the passphrase.
KEY=$(mktemp -d)/tvkey
cp ~/.ssh/webos_<id> "$KEY" && chmod 600 "$KEY"
ssh-keygen -p -P '<passphrase>' -N '' -f "$KEY"

SSH=(ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa
     -i "$KEY" -p 9922 prisoner@192.168.0.186)

# Device information.
"${SSH[@]}" 'cat /var/run/nyx/device_info.json'

# Install an IPK.
cat app.ipk | "${SSH[@]}" 'mkdir -p /media/developer/temp &&
  cat > /media/developer/temp/app.ipk &&
  luna-send-pub -i -f luna://com.webos.appInstallService/dev/install \
    "{\"id\":\"com.ares.defaultName\",\"ipkUrl\":\"/media/developer/temp/app.ipk\",\"subscribe\":true}"'
# Stop with Ctrl-C after "state": "installed", then delete the IPK:
"${SSH[@]}" 'rm -f /media/developer/temp/app.ipk'

# Delete the key copy.
rm -f "$KEY"
```

The TV accepts only `ssh-rsa`, so the `+ssh-rsa` options are necessary.

`luna-send-pub` app launch calls from SSH do not start apps. Start apps
from the TV remote, or with `ares-launch` when it can connect.

## Before you install an app

1. Download the `.ipk` from the release page.
2. Compare its SHA-256 with the release digest:
   `gh release view -R <owner>/<repo> --json assets -q '.assets[]|.name+" "+.digest'`.
3. Make sure the app supports ARM and webOS 6.
