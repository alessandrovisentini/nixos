# Everything for detachable/convertible tablets and touchscreens:
# mode detection, touch gestures, auto-rotation.
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

  modeDaemon = pkgs.writers.writePython3Bin "mode-daemon" {
    libraries = with pkgs.python3Packages; [evdev];
    doCheck = false;
  } (builtins.readFile (dotfilesConfig + "/wm-scripts/mode-daemon.py"));

  applyMode = pkgs.writeShellScriptBin "apply-mode" (builtins.readFile (dotfilesConfig + "/wm-scripts/apply-mode.sh"));
  modeCycle = pkgs.writeShellScriptBin "mode-cycle" (builtins.readFile (dotfilesConfig + "/wm-scripts/mode-cycle.sh"));
  lisgdSway = pkgs.writeShellScriptBin "lisgd-sway" (builtins.readFile (dotfilesConfig + "/wm-scripts/lisgd-sway.sh"));
  swayRotate = pkgs.writeShellScriptBin "sway-rotate" (builtins.readFile (dotfilesConfig + "/wm-scripts/sway-rotate.sh"));
  swayWsShift = pkgs.writeShellScriptBin "sway-ws-shift" (builtins.readFile (dotfilesConfig + "/wm-scripts/sway-ws-shift.sh"));

  # Detachable convertibles (SW_TABLET_MODE switch).
  tabletPkgs = [modeDaemon applyMode modeCycle];

  # Touchscreen gestures + key injection, added to programs.sway.extraPackages.
  swayTouchPkgs = with pkgs; [lisgd wtype lisgdSway swayWsShift];
in {
  environment.systemPackages =
    lib.optionals dev.hasTabletMode tabletPkgs;

  programs.sway.extraPackages = lib.mkIf dev.hasTouchscreen swayTouchPkgs;

  # Tablet-mode detector
  systemd.user.services."mode-daemon" = lib.mkIf dev.hasTabletMode {
    description = "Tablet-mode detection daemon";
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];
    path =
      [applyMode]
      ++ (with pkgs; [coreutils systemd procps libnotify sway jq]);
    environment = {
      DETACHABLE_TOUCHPAD_SWAY_ID = dev.detachableTouchpadSwayId;
      DETACHABLE_KEYBOARD_HINTS = lib.concatStringsSep "|" dev.detachableKeyboardHints;
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${modeDaemon}/bin/mode-daemon";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  # Auto-rotation (started/stopped by apply-mode, tablet only)
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
