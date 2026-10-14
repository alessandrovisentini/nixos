{...}: {
  services.displayManager.ly.enable = true;
  services.displayManager.defaultSession = "sway";

  # Avoid writing a log on every login
  services.displayManager.ly.settings.session_log = "null";

  # Avoid the fingerprint reader for login
  security.pam.services.ly.fprintAuth = false;

  # GNOME greeter instead of ly, pointable and with an on-screen keyboard for the password.
  # Set ly.enable above to false and uncomment.
  # services.displayManager.gdm.enable = true;
  # programs.dconf.profiles.gdm.databases = [
  #   {settings."org/gnome/desktop/a11y/applications".screen-keyboard-enabled = true;}
  # ];
}
