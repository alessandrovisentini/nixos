{pkgs, ...}: let
  # Performance power profile and max GPU clocks while a game runs, back to
  # normal after. Without it the CPU sits at base clock and starves the GPU.
  gamePerf = pkgs.writeShellScript "game-perf" ''
    case "$1" in
      on)  profile=performance; level=high ;;
      off) profile=balanced;    level=auto ;;
      *)   echo "usage: game-perf on|off" >&2; exit 1 ;;
    esac

    # Skip knobs that do not exist. Builtins only, gamemode runs this with an empty PATH.
    p=/sys/firmware/acpi/platform_profile
    [ -e "$p" ] && echo "$profile" > "$p"

    for f in /sys/class/drm/card[0-9]/device/power_dpm_force_performance_level; do
      [ -e "$f" ] && echo "$level" > "$f"
    done
  '';
in {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    # gamescopeSession stays off, it breaks plain Steam launches (setuid bwrap).
  };

  # Used per game through Steam launch options ("gamescope ... -- %command%").
  # capSysNice stays off, its wrapper crashes inside the Steam sandbox.
  programs.gamescope.enable = true;

  # The hooks flip power profile and GPU clocks for the length of the game.
  programs.gamemode = {
    enable = true;
    settings.custom = {
      start = "/run/wrappers/bin/sudo ${gamePerf} on";
      end = "/run/wrappers/bin/sudo ${gamePerf} off";
    };
  };

  # Sway has no polkit agent, so gamemode's helpers would get denied. Allow them.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("com.feralinteractive.GameMode.") === 0
          && subject.active && subject.local) {
        return polkit.Result.YES;
      }
    });
  '';

  # The hooks need root for sysfs. Passwordless sudo for these two calls only.
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
}
