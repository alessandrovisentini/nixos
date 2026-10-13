{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./specialisation.nix
    ./base.nix
    ./hardware.nix
    ./power.nix
    ./main_user.nix
    ./apps.nix
    ./gaming.nix
    ./display_manager.nix
    ./sway.nix
    ./development.nix
    ./jellyfin.nix
    ./printing.nix
    ./mime_apps.nix
    ./nix.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.enable = true;
    loader.systemd-boot.configurationLimit = 5;

    initrd.systemd.enable = true;

    consoleLogLevel = 0;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

    plymouth.enable = true; # LUKS password screen
  };

  system.stateVersion = "25.11";
}
