{pkgs, ...}: let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz";
  # Parent of this repo, dotfiles live next to it.
  reposHome = builtins.dirOf (toString ./.);
in {
  imports = [
    (import "${home-manager}/nixos")
  ];

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

    REPOS_HOME = reposHome;
    TTRPG_NOTES_HOME = "${reposHome}/ttrpg-notes";
    NETHACKOPTIONS = "@${reposHome}/dotfiles/config/nethack/nethackrc";

    # Native Wayland for Electron and Firefox, XWayland is blurry.
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Aliases
  environment.shellAliases = {
    t = "$REPOS_HOME/dotfiles/scripts/t.sh";
    tt = "$REPOS_HOME/dotfiles/scripts/tt.sh";

    ai = "$REPOS_HOME/dotfiles/scripts/ai/ai.sh";
    h = "$REPOS_HOME/dotfiles/scripts/ai/h.sh";

    rip-cd = "$REPOS_HOME/dotfiles/scripts/rip-cd.sh";
  };

  # Home Manager
  home-manager.users.alessandrovisentini = {
    lib,
    pkgs,
    config,
    ...
  }: {
    home.stateVersion = "26.05";

    home.username = "alessandrovisentini";

    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Adwaita-dark";
          cursor-theme = "Adwaita";
        };
        "org/gnome/nm-applet" = {
          disable-connected-notifications = true;
          disable-disconnected-notifications = true;
          disable-vpn-notifications = true;
          suppress-wireless-networks-available = true;
        };
      };
    };

    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };

      gtk4.theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
    };

    qt = {
      enable = true;
      style.name = "adwaita-dark";
    };
  };
}
