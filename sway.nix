{pkgs, ...}: {
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs;
      [
        # lock + idle
        swaylock
        swayidle

        # launcher
        rofi

        # bar
        waybar

        # emoji picker
        rofimoji

        # notifications
        libnotify
        swaynotificationcenter

        # brightness
        brightnessctl

        # network
        networkmanagerapplet

        # audio
        pwvucontrol
        pulseaudio

        # media keys
        playerctl

        # screenshot + color picker
        sway-contrib.grimshot
        grim
        slurp
        imagemagick_light

        # mirroring
        wl-mirror

        # icons
        adwaita-icon-theme
      ];
  };

  # File manager
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
    ];
  };
  programs.xfconf.enable = true;
  services.tumbler.enable = true;
  services.gvfs.enable = true;

  # Bluetooth
  services.blueman.enable = true;

  # Headset buttons to playerctl. bluez ships the unit, only enable it here.
  systemd.user.services.mpris-proxy = {
    wantedBy = ["default.target"];
    serviceConfig.Restart = "on-failure";
  };

  # No fingerprint on the lock screen, it makes typing the password slow.
  security.pam.services.swaylock.fprintAuth = false;

  # Screenshare + file pickers
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    # Without this GTK apps find no file picker under sway.
    # Pickers go to gtk, screen capture to wlr.
    config = {
      common = {
        default = ["gtk"];
        "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
        "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
      };
      sway = {
        default = ["gtk"];
        "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
        "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
      };
    };
  };
}
