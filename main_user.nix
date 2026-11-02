{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  # User and group
  users.users.alessandrovisentini = {
    isNormalUser = true;
    uid = 1000;
    group = "alessandrovisentini";
    description = "alessandrovisentini";
    extraGroups = ["networkmanager" "wheel" "video" "audio" "disk" "pcap" "input"];
  };
  users.groups.alessandrovisentini = {
    gid = 1000;
  };

  xdg.mime.enable = true;
  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;

  # Polkit
  security.polkit.enable = true;

  # dconf
  programs.dconf.enable = true;

  # Keyring
  services.gnome.gnome-keyring.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.dejavu-sans-mono
    adwaita-fonts
  ];

  # Qt theme
  qt = {
    enable = true;
    style = "adwaita-dark";
  };

  # Sound
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

  # Session variables
  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    # Native Wayland for Electron and Firefox, XWayland is blurry.
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Desktop defaults (dark theme, nm-applet quiet) from dotfiles, every session.
  programs.dconf.profiles.user.databases = [
    {keyfiles = [../dotfiles/config/desktop];}
  ];
}
