{
  config,
  lib,
  ...
}: let
  dev = config.local.device;
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

    # Feral GameMode: switches the CPU governor to performance and bumps
    # process/GPU priority while a game is running.
    programs.gamemode.enable = true;
  };
}
