{...}: {
  services.displayManager.ly.enable = true;
  services.displayManager.defaultSession = "sway";

  # Keep fingerprint out of the greeter's auth path. fprintd sits inline as
  # "auth sufficient" and blocks waiting on the reader before the typed
  # password is accepted, which makes login painfully slow. Fingerprint stays
  # available for sudo/polkit.
  security.pam.services.ly.fprintAuth = false;
}
