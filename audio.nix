{
  pkgs,
  settings,
  ...
}: let
  unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
    config.allowUnfree = true;
  };
in {
  # Sound server
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    extraConfig.pipewire.adjust-sample-rate = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.min-quantum" = 256;
        "default.clock.quantum" = 512;
        "default.clock.max-quantum" = 2048;
      };
    };
  };

  users.users.${settings.username}.packages = with pkgs; [
    # Routing + effects
    easyeffects
    qpwgraph

    # Music
    musescore
    audacity
    transcribe
    tauon

    # CD ripping
    whipper
    cdrdao
    cdparanoia
    flac

    # DAW + plugin host
    ardour
    carla

    # Samplers
    sfizz
    drumgizmo
    x42-avldrums
    hydrogen

    # Synths
    surge-XT
    distrho-ports # vitalium and others
    odin2
    helm
    dexed
    cardinal
    setbfree
    zynaddsubfx

    # Effects
    lsp-plugins
    x42-plugins
    dragonfly-reverb
    airwindows-lv2
    chow-tape-model

    # Soundfonts
    soundfont-fluid
    soundfont-generaluser
    soundfont-ydp-grand
  ];
}
