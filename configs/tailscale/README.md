# Tailscale policy

`policy.hujson` is a copy of the live tailnet policy. Edit it in the admin
console or with the API, then copy the result here.

If a tailnet connection fails, check this policy before you debug the server.

## Access

| Source | Destination | Ports |
|---|---|---|
| My devices (untagged) | My devices (untagged) | all |
| My devices (untagged) | `tag:home-server` (nixos-laptop, `100.121.29.45`) | TCP 22, 2283, 3389, 3773, 8080, 8081, 8083, 8318, 9696 |
| `tag:home-server` | any tailnet device | none |

The grant uses the host IP, not the tag. A new port on nixos-laptop needs a
new entry in the grant and in the `tests` block.

`tag:home-server` has internet access. The policy does not control it.

arbit-vm comes from another tailnet. Its owner's policy controls access to it.

Funnel is off for all devices. Serve still works.

## Roll back

Remove the tag from the device in the admin console. The device then belongs
to my user again and gets full access to my devices at once.

## API access

The OAuth client has two scopes: Policy File (write) and Devices Core (read).
The credentials are in `~/.config/tailscale-api/oauth.env`, outside this repo.
The client cannot set tags.
