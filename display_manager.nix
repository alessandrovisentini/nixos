{...}: {
  services.displayManager.ly.enable = true;
  services.displayManager.defaultSession = "sway";

  # Avoid writing a log on every login
  services.displayManager.ly.settings.session_log = "null";

  # Avoid the fingerprint reader for login
  security.pam.services.ly.fprintAuth = false;
}
