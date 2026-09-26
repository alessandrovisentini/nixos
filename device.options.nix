{lib, ...}: {
  options.local.device = {
    hasFingerprint = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Has a fingerprint reader. Enables fprintd.";
    };

    hasIpu6Camera = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Has an Intel IPU6 MIPI camera. Blacklists the broken ISP modules and disables the libcamera monitor.";
    };

    hasThunderbolt = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Has a Thunderbolt controller. Enables bolt.";
    };

    hasGaming = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enables gaming software (Steam with Remote Play and dedicated server firewall openings).";
    };

    hasJellyfin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Runs the Jellyfin media server, with Intel hardware transcoding and a shared library directory. Opt-in per device.";
    };

    hasGnome = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enables the GNOME desktop as an extra session alongside Sway. Sway stays the default session.";
    };

    userName = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "Primary user account name. Owns the UID 1000 user and the home-manager profile.";
    };

    hostName = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "Networking hostname.";
    };
  };
}
