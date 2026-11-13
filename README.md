# nixos

NixOS system configuration.

## Quick install

Run on NixOS:

```bash
curl -fsSL https://raw.githubusercontent.com/alessandrovisentini/nixos/main/install.sh | bash
```

Installer steps:

- clones this repo to `~/Development/repos/nixos`
- clones the [dotfiles](https://github.com/alessandrovisentini/dotfiles) to `~/Development/repos/dotfiles`
- links `~/.config/*`
- symlinks `configuration.nix` into `/etc/nixos`
- runs `nixos-rebuild switch`.
