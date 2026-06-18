# nixos

NixOS system configuration plus an installer that links it into `/etc/nixos`
and pulls in the [dotfiles](https://github.com/alessandrovisentini/dotfiles)
config for `~/.config`.

## Quick install

Run on a NixOS machine:

```bash
curl -fsSL https://raw.githubusercontent.com/alessandrovisentini/nixos/main/install.sh | bash
```

It clones this repo to `~/Development/repos/nixos`, clones `dotfiles` to
`~/Development/repos/dotfiles`, links `~/.config/*` and `~/.claude/*`, symlinks
`configuration.nix` into `/etc/nixos`, picks the per-device profile, and runs
`nixos-rebuild switch`.

## What it does

1. **symlinks** — links `dotfiles/config/*` into `~/.config/*` and the Claude
   config into `~/.claude`
2. **nixos** — reverse-links `hardware-configuration.nix`, symlinks
   `configuration.nix` into `/etc/nixos`, and links `device.nix` to the matching
   `devices/<name>.nix`
3. **rebuild** — `sudo nixos-rebuild switch`
4. **post** — OS-specific post-install commands

## Running only some steps

```bash
./install/install.sh symlinks      # only recreate ~/.config symlinks
./install/install.sh nixos         # only set up /etc/nixos symlinks
./install/install.sh --help        # full step list
```

## Device profiles

`device.nix` is symlinked to one of `devices/*.nix` based on
`/sys/class/dmi/id/product_version`. Add a new machine by dropping
`devices/<name>.nix` and adding a matcher in `setup-device.sh`.
