# Phosh, the mobile shell, as an extra session next to Sway.
# Gated by the device flags from device.options.nix.
{
  config,
  lib,
  ...
}: let
  dev = config.local.device;
in {
  config = lib.mkIf dev.hasPhosh {
    services.xserver.desktopManager.phosh = {
      enable = true;
      user = dev.userName;
      group = dev.userName;

      phocConfig = {
        xwayland = "true";

        # Phosh lays itself out for a phone. Scaling the panel by 2 leaves it
        # with roughly phone-sized logical pixels, which is what its layouts
        # and the lock screen keypad are drawn for.
        outputs.${dev.internalOutput}.scale = 2;
      };
    };

    # The upstream module also ships phosh as its own display manager: a unit
    # that takes over tty1 at boot and logs a single user straight in. Here
    # phosh is one session among others and the greeter starts it, so that unit
    # must never run.
    systemd.services.phosh.enable = false;

    # Phosh pulls in the GNOME core services, which turn power-profiles-daemon
    # on by default. It fights auto-cpufreq over the same knobs.
    services.power-profiles-daemon.enable = false;

    # Same source. It exports GTK_IM_MODULE=ibus, which takes GTK apps off the
    # Wayland text-input path that the on-screen keyboard types through.
    i18n.inputMethod.enable = false;
  };
}
