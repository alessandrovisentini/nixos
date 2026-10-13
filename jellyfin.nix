{
  lib,
  pkgs,
  ...
}: let
  # iGPU render node
  renderNode = "/dev/dri/renderD128";
in {
  services.jellyfin = {
    enable = true;
    openFirewall = true;

    # Runs as my user so it can read media anywhere under my home.
    user = "alessandrovisentini";
    group = "alessandrovisentini";

    hardwareAcceleration = {
      enable = true;
      # qsv instead of vaapi: it has the Intel-only extras (low power encode, tone mapping).
      type = "qsv";
      device = renderNode;
    };

    # Rewrite encoding.xml on every rebuild, or an old file keeps hw accel off.
    # Side effect: the transcoding page in the web UI no longer saves, change things here.
    forceEncodingConfig = true;

    transcoding = {
      enableHardwareEncoding = true;
      enableToneMapping = true;

      # Needs HuC firmware, the kernel loads it by itself on this chip.
      enableIntelLowPowerEncoding = true;

      # Everything this iGPU can decode.
      hardwareDecodingCodecs = {
        h264 = true;
        hevc = true;
        hevc10bit = true;
        hevcRExt10bit = true;
        hevcRExt12bit = true;
        mpeg2 = true;
        vc1 = true;
        vp8 = true;
        vp9 = true;
        av1 = true;
      };

      # No AV1 encoder on this chip, leave it off or it falls back to the CPU.
      hardwareEncodingCodecs.hevc = true;
    };
  };

  # GPU access for transcoding
  users.users.alessandrovisentini.extraGroups = ["render"];

  # Runs as my user, so it also gets the docker group. Hide the socket, docker is basically root.
  systemd.services.jellyfin.serviceConfig.InaccessiblePaths = ["-/run/docker.sock"];

  # Installed but not started at boot, start it by hand.
  systemd.services.jellyfin.wantedBy = lib.mkForce [];

  # Tools to check the GPU is really doing the transcoding
  environment.systemPackages = with pkgs; [
    libva-utils
    intel-gpu-tools
  ];
}
