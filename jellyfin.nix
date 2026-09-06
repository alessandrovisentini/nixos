{
  config,
  lib,
  pkgs,
  ...
}: let
  dev = config.local.device;

  # The iGPU render node: both the media engine and the OpenCL device used for
  # tone mapping are reached through it.
  renderNode = "/dev/dri/renderD128";
in {
  config = lib.mkIf dev.hasJellyfin {
    services.jellyfin = {
      enable = true;
      openFirewall = true;

      # Runs as the login user instead of a service account, so libraries
      # anywhere under the home are readable with no shared directory and no
      # extra groups to keep in sync.
      user = dev.userName;
      group = dev.userName;

      hardwareAcceleration = {
        enable = true;
        # QSV over plain VA-API: it drives the same Intel media engine through
        # oneVPL and is where Jellyfin keeps the Intel-only features, namely
        # low-power encoding and the full-hardware tone mapping pipeline.
        type = "qsv";
        device = renderNode;
      };

      # Without this the encoding settings below are written only when
      # encoding.xml is missing, so an older file would silently keep hardware
      # acceleration off. The cost is that the transcoding page in the web
      # dashboard no longer persists; change things here instead.
      forceEncodingConfig = true;

      transcoding = {
        enableHardwareEncoding = true;
        enableToneMapping = true;

        # Low-power (VDENC) encoding. It needs authenticated HuC firmware,
        # which i915 loads on its own for this generation.
        enableIntelLowPowerEncoding = true;

        # Everything the media engine reports as decodable.
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

        # H.264 is always on. There is no AV1 encoder on this hardware, only a
        # decoder, so leave that off or transcodes fall back to the CPU.
        hardwareEncodingCodecs.hevc = true;
      };
    };

    # The render node is world-accessible by default; joining the group means
    # the transcoder does not depend on that staying true.
    users.users.${dev.userName}.extraGroups = ["render"];

    # A service running as the login user inherits that user's groups, docker
    # among them, and the docker socket is one step away from root.
    systemd.services.jellyfin.serviceConfig.InaccessiblePaths = ["-/run/docker.sock"];

    # vainfo and intel_gpu_top, to check the media engine is really the one
    # doing the transcoding.
    environment.systemPackages = with pkgs; [
      libva-utils
      intel-gpu-tools
    ];
  };
}
