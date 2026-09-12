{
  config,
  lib,
  ...
}: let
  dev = config.local.device;
in {
  services.displayManager.defaultSession = "sway";

  # ly is a TTY greeter: fine on a laptop, unusable on a detachable that boots
  # with the keyboard left in a bag. Those devices get GDM, which is pointable
  # and can raise an on-screen keyboard over the password field.
  services.displayManager.ly.enable = !dev.hasTouchGreeter;
  services.displayManager.gdm.enable = dev.hasTouchGreeter;

  # ly writes a per-session log to the user's home by default. "null" is ly's
  # documented value for disabling it ("If null, no session log will be created").
  # String, not Nix null, so the line renders as `session_log=null` rather than
  # being dropped and falling back to the default path.
  services.displayManager.ly.settings.session_log = "null";

  # Keep fingerprint out of the greeter's auth path. fprintd sits inline as
  # "auth sufficient" and blocks waiting on the reader before the typed
  # password is accepted, which makes login painfully slow. Fingerprint stays
  # available for sudo/polkit.
  security.pam.services.ly = lib.mkIf (!dev.hasTouchGreeter) {fprintAuth = false;};

  # GDM's greeter reads the "gdm" dconf profile rather than any user's. Turning
  # the screen keyboard on there is what makes the password field typeable with
  # nothing but the touchscreen.
  programs.dconf.profiles = lib.mkIf dev.hasTouchGreeter {
    gdm.databases = [
      {
        settings."org/gnome/desktop/a11y/applications".screen-keyboard-enabled = true;
      }
    ];
  };
}
