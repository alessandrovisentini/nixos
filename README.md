# nixos

NixOS system configuration plus an installer that links it into `/etc/nixos` and pulls in the [dotfiles](https://github.com/alessandrovisentini/dotfiles) config for `~/.config`.

## Quick install

Run on a NixOS machine:

```bash
curl -fsSL https://raw.githubusercontent.com/alessandrovisentini/nixos/main/install.sh | bash
```

It clones this repo to `~/Development/repos/nixos`, clones `dotfiles` to `~/Development/repos/dotfiles`, links `~/.config/*`, symlinks `configuration.nix` into `/etc/nixos`, and runs `nixos-rebuild switch`.

## What it does

1. **symlinks** — links `dotfiles/config/*` into `~/.config/*`, and makes `~/.bashrc` and `~/.profile` source `dotfiles/config/shell/env.sh` (aliases and env vars, like `REPOS_HOME`)
2. **nixos** — reverse-links `hardware-configuration.nix` and symlinks `configuration.nix` into `/etc/nixos`
3. **rebuild** — `sudo nixos-rebuild switch`
4. **post** — OS-specific post-install commands
