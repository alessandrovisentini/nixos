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
    # if, not &&: a skipped knob (no eGPU) must not fail the script.
    p=/sys/firmware/acpi/platform_profile
    if [ -e "$p" ]; then echo "$profile" > "$p"; fi

    for f in /sys/class/drm/card[0-9]/device/power_dpm_force_performance_level; do
      if [ -e "$f" ]; then echo "$level" > "$f"; fi
    done
  '';
in {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # The hooks flip power profile and GPU clocks for the length of the game.
  programs.gamemode = {
    enable = true;
    settings = {
      # Pinning games to the P-cores crashes Divinity: Original Sin 2 at startup,
      # a race in the game that only shows with fewer cores than it counted.
      cpu.pin_cores = "no";
      custom = {
        start = "/run/wrappers/bin/sudo ${gamePerf} on";
        end = "/run/wrappers/bin/sudo ${gamePerf} off";
      };
    };
  };

  # Lutris data lives with the games, so copying ~/Games is enough on a new machine.
  # The folder must exist first, Lutris fails on a link to nothing.
  systemd.user.tmpfiles.users.alessandrovisentini.rules = [
    "d %h/Games/lutris - - - -"
    "L %h/.local/share/lutris - - - - %h/Games/lutris"
  ];

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
