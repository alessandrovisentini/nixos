#!/usr/bin/env bash
# Bootstrap entry for NixOS, invoked via `curl … | bash`. Ensures git,
# clones this repo, then hands off to install/install.sh (which also
# clones the dotfiles repo for the actual config files).

set -e

REPO_URL="https://github.com/alessandrovisentini/nixos.git"
TARGET_DIR="$HOME/Development/repos/nixos"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

if [[ ! -f /etc/nixos/configuration.nix ]] && ! command -v nixos-rebuild &>/dev/null; then
    log_error "This installer targets NixOS, which was not detected."
    exit 1
fi

# git is provided on-demand via nix-shell when not already installed.
run_git() {
    if command -v git &>/dev/null; then
        git "$@"
    else
        local args
        args=$(printf '%q ' "$@")
        nix-shell -p git --run "git $args"
    fi
}

log_info "Creating directory structure..."
mkdir -p "$HOME/Development/repos"

if [[ -d "$TARGET_DIR/.git" ]]; then
    log_info "Repository exists at $TARGET_DIR. Updating..."
    run_git -C "$TARGET_DIR" pull --ff-only || log_warning "Failed to update repository. Continuing with existing files."
else
    log_info "Cloning nixos repository..."
    run_git clone "$REPO_URL" "$TARGET_DIR" || {
        log_error "Failed to clone repository. Check your internet connection."
        exit 1
    }
fi

chmod +x "$TARGET_DIR/install/install.sh" "$TARGET_DIR/setup-device.sh"
exec "$TARGET_DIR/install/install.sh" "$@"
