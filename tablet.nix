# Everything for touchscreens: touch gestures, auto-rotation.
# Gated by the device flags from device.options.nix.
{
  config,
  lib,
  pkgs,
  ...
}: let
  dev = config.local.device;

  # Sibling dotfiles repo (see install layout): $REPOS_HOME/dotfiles.
  reposHome = ../.;
  dotfilesConfig = reposHome + "/dotfiles/config";

  lisgdSway = pkgs.writeShellScriptBin "lisgd-sway" (builtins.readFile (dotfilesConfig + "/wm-scripts/lisgd-sway.sh"));
  swayRotate = pkgs.writeShellScriptBin "sway-rotate" (builtins.readFile (dotfilesConfig + "/wm-scripts/sway-rotate.sh"));
  swayWsShift = pkgs.writeShellScriptBin "sway-ws-shift" (builtins.readFile (dotfilesConfig + "/wm-scripts/sway-ws-shift.sh"));

  # Touchscreen gestures + key injection, added to programs.sway.extraPackages.
  swayTouchPkgs = with pkgs; [lisgd wtype lisgdSway swayWsShift];
in {
  programs.sway.extraPackages = lib.mkIf dev.hasTouchscreen swayTouchPkgs;

  # Auto-rotation (started from the device's sway config)
  systemd.user.services."sway-rotate" = lib.mkIf dev.hasAccelerometer {
    description = "Auto-rotate the Sway panel from the accelerometer";
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];
    path = with pkgs; [iio-sensor-proxy sway coreutils gnugrep];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${swayRotate}/bin/sway-rotate ${dev.internalOutput}";
      # always, not on-failure: monitor-sensor can exit cleanly when
      # iio-sensor-proxy drops its claim across suspend, ending the
      # script's read loop with exit 0 and leaving rotation dead.
      Restart = "always";
      RestartSec = 3;
    };
  };
}
