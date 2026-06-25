{...}: {
  services.displayManager.ly.enable = true;
  services.displayManager.defaultSession = "sway";

  # ly writes a per-session log to the user's home by default. "null" is ly's
  # documented value for disabling it ("If null, no session log will be created").
  # String, not Nix null, so the line renders as `session_log=null` rather than
  # being dropped and falling back to the default path.
  services.displayManager.ly.settings.session_log = "null";

  # Keep fingerprint out of the greeter's auth path. fprintd sits inline as
  # "auth sufficient" and blocks waiting on the reader before the typed
  # password is accepted, which makes login painfully slow. Fingerprint stays
  # available for sudo/polkit.
  security.pam.services.ly.fprintAuth = false;
}
