{pkgs, ...}: {
  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # VA-API
      vpl-gpu-rt # Quick Sync
      intel-compute-runtime # OpenCL, for tone mapping
    ];
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Enable = "Source,Sink,Media,Socket";
  };

  # Battery
  services.upower.enable = true;

  # Thunderbolt
  services.hardware.bolt.enable = true;

  # Fingerprint, kept always running instead of started on demand
  services.fprintd.enable = true;
  systemd.services.fprintd = {
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "simple";
  };
}
