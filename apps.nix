{
  lib,
  pkgs,
  ...
}: let
  unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
    config.allowUnfree = true;
  };

  # Qt 6.12 qml validation code clashes with `using namespace` in the unity build.
  audacity-unstable = unstable.audacity.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        find . -name CMakeLists.txt -exec sed -i \
          's/qt_add_qml_module(\([A-Za-z0-9_]*\)$/qt_add_qml_module(\1 NO_GENERATE_AOT_VALIDATION/' {} +
      '';
  });
in {
  environment.systemPackages = with pkgs; [
    # CLI utilities
    nano
    wget
    htop
    fastfetch
    wl-screenrec
    wl-clipboard
    gcc_multi
    dig
    traceroute
    ripgrep
    fzf
    ffmpeg
    unzip
    zip

    # Development
    nodejs
    cargo
    go
    python314
    docker-compose
    delta
    glow
    jq
    gnumake
    tree-sitter
    markdownlint-cli
    alejandra
    android-tools
    gh
  ];

  virtualisation.docker.enable = true;

  programs.nix-ld.enable = true; # run normal linux binaries
  services.fwupd.enable = true;

  users.users.alessandrovisentini.packages = with pkgs; [
    alacritty
    baobab # disk analyzer
    gnome-calculator
    gnome-calendar
    papers
    simple-scan
    geary
    protonmail-bridge
    protonmail-bridge-gui
    proton-pass
    tor-browser
    deja-dup
    telegram-desktop
    pdftk
    libreoffice
    f3d
    imv
    yt-dlp
    vlc
    mpv
    calibre
    gimp
    inkscape-with-extensions
    obsidian
    ungoogled-chromium
    discord
    easyeffects
    qpwgraph
    musescore
    audacity-unstable
    transcribe
    whipper
    cdrdao
    cdparanoia
    flac
    vscodium
    pdfarranger
    unstable.claude-code
    nethack
    tauon
    newsflash
    krita
  ];

  # Browsers
  programs.firefox.enable = true;

  programs.git.enable = true;
  programs.git.lfs.enable = true;

  programs.tmux.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    # my config needs Neovim 0.12+
    package = unstable.neovim-unwrapped;
  };

  programs.tcpdump.enable = true;

  programs.lazygit.enable = true;

  programs.gnome-disks.enable = true;

  programs.seahorse.enable = true;

  # Installed but not started at boot, start it by hand.
  services.deluge.enable = true;
  systemd.services.deluged.wantedBy = lib.mkForce [];

  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  # AppImages
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
}
