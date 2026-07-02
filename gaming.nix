{
  config,
  lib,
  pkgs,
  ...
}: let
  dev = config.local.device;

  # While a game runs, switch the firmware to its performance power profile and
  # lock the GPU to its top clocks; put both back on exit. Some machines
  # otherwise hold the CPU near its base clock and starve the GPU. Wired to the
  # gamemode hooks below so it only kicks in during games.
  gamePerf = pkgs.writeShellScript "game-perf" ''
    case "$1" in
      on)  profile=performance; level=high ;;
      off) profile=balanced;    level=auto ;;
      *)   echo "usage: game-perf on|off" >&2; exit 1 ;;
    esac

    # Only write the knobs that exist, so this is a no-op on machines without
    # them. Shell builtins only: gamemode runs this with a bare PATH.
    p=/sys/firmware/acpi/platform_profile
    [ -e "$p" ] && echo "$profile" > "$p"

    for f in /sys/class/drm/card[0-9]/device/power_dpm_force_performance_level; do
      [ -e "$f" ] && echo "$level" > "$f"
    done
  '';
in {
  config = lib.mkIf dev.hasGaming {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      # Leave gamescopeSession off: together with capSysNice it installs a
      # setuid bwrap wrapper, and the current bubblewrap is built without
      # setuid support, so plain Steam launches then fail.
    };

    # Per-game compositor for scaling, refresh and frame-limit control,
    # used through Steam launch options ("gamescope ... -- %command%").
    #
    # capSysNice stays off on purpose: it installs a setcap wrapper that
    # aborts with "failed to inherit capabilities" when gamescope runs inside
    # the Steam runtime sandbox, killing the game launch. Its realtime
    # priority only ever applied to a full gamescope session, which we don't
    # run, and the sandbox strips the capability anyway.
    programs.gamescope.enable = true;

    # GameMode tunes the CPU governor and process priority while a game runs.
    # The custom hooks below also flip the power profile and GPU clocks for the
    # duration of the game.
    programs.gamemode = {
      enable = true;
      settings.custom = {
        start = "/run/wrappers/bin/sudo ${gamePerf} on";
        end = "/run/wrappers/bin/sudo ${gamePerf} off";
      };
    };

    # GameMode runs its tuning through privileged helpers. On a session with no
    # polkit agent those get denied and the tuning never applies, so allow them
    # for the active local user.
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id.indexOf("com.feralinteractive.GameMode.") === 0
            && subject.active && subject.local) {
          return polkit.Result.YES;
        }
      });
    '';

    # The hooks run as the user but writing those files needs root. Allow just
    # these two calls without a password, nothing else.
    security.sudo.extraRules = [
      {
        groups = ["wheel"];
        commands = [
          {
            command = "${gamePerf} on";
            options = ["NOPASSWD"];
          }
          {
            command = "${gamePerf} off";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  };
}
