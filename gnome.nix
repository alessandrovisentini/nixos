{
  lib,
  pkgs,
  ...
}: let
  dconfDir = ../dotfiles/config/gnome;

  extensions = pkgs.runCommand "gnome-shell-extensions" {} ''
    mkdir -p $out/share/gnome-shell
    cp -r ${../dotfiles/config/gnome-extensions} $out/share/gnome-shell/extensions
  '';

  # Lock every key in the keyfile
  dconfLocks = let
    lines = lib.splitString "\n" (builtins.readFile "${dconfDir}/dconf-settings.ini");
    step = acc: line: let
      section = builtins.match "\\[(.*)]" line;
      key = builtins.match "([A-Za-z0-9-]+)=.*" line;
    in
      if section != null
      then acc // {section = builtins.head section;}
      else if key != null
      then acc // {locks = acc.locks ++ ["/${acc.section}/${builtins.head key}"];}
      else acc;
  in
    (builtins.foldl' step {
        section = "";
        locks = [];
      }
      lines)
    .locks;
in {
  services.desktopManager.gnome.enable = true;
  # Can't remove this: GNOME only locks the screen when GDM is running.
  services.displayManager.gdm.enable = true;

  services.gnome.games.enable = false;
  services.gnome.core-apps.enable = false;
  services.power-profiles-daemon.enable = false; # conflicts with auto-cpufreq
  environment.gnome.excludePackages = with pkgs; [gnome-tour gnome-user-docs];
  users.users.alessandrovisentini.packages = with pkgs; [gnome-tweaks];

  services.gnome.gnome-browser-connector.enable = true;
  environment.systemPackages = [extensions];

  services.udev.packages = with pkgs; [gnome-settings-daemon];
  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
    {
      keyfiles = [dconfDir];
      locks = dconfLocks;
    }
  ];
}
