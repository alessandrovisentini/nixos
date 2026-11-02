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

  # No fingerprint on the lock screen, it makes typing the password slow.
  security.pam.services.swaylock.fprintAuth = false;

  # Screenshare + file pickers. Which portal handles what is in dotfiles.
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };
}
