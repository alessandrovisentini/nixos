{
  lib,
  pkgs,
  ...
}: let
  # Settings live in dotfiles, next to this repo.
  dconfDir = ../dotfiles/config/gnome;

  # Local extension, also kept in dotfiles.
  moveWithoutFollow = pkgs.stdenvNoCC.mkDerivation {
    pname = "gnome-shell-extension-move-without-follow";
    version = "0.1.0";
    src = ../dotfiles/config/gnome-extensions/move-without-follow;
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      target="$out/share/gnome-shell/extensions/move-without-follow@local"
      mkdir -p "$target"
      install -m644 extension.js metadata.json -t "$target/"
      runHook postInstall
    '';
    passthru.extensionUuid = "move-without-follow@local";
  };

  # Lock every key in the keyfile, lockAll only covers settings written in Nix.
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

  services.gnome.games.enable = false;
  services.gnome.core-apps.enable = false;
  services.power-profiles-daemon.enable = false; # conflicts with auto-cpufreq
  environment.gnome.excludePackages = with pkgs; [gnome-tour gnome-user-docs];
  users.users.alessandrovisentini.packages = with pkgs; [gnome-tweaks];

  services.gnome.gnome-browser-connector.enable = true;
  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.simple-workspaces-bar
    gnomeExtensions.disable-workspace-switcher-overlay
    moveWithoutFollow
  ];

  services.udev.packages = with pkgs; [gnome-settings-daemon];
  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
    {
      keyfiles = [dconfDir];
      locks = dconfLocks;
    }
  ];
}
