{lib, ...}: {
  specialisation = {
    # eGPU only: iGPU off, everything runs on the AMD card.
    egpu.configuration = {
      system.nixos.tags = ["egpu"];

      boot = {
        initrd.kernelModules = ["amdgpu"];
        # Intel DRM never loads. simpledrm stays: the LUKS password prompt needs
        # a screen before the eGPU is up, without it the system does not boot.
        kernelParams = ["amdgpu.pcie_gen_cap=0x40000" "module_blacklist=i915,xe"];
        blacklistedKernelModules = ["i915" "xe"];
      };

      services.xserver.videoDrivers = lib.mkForce ["amdgpu"];

      hardware.graphics = lib.mkForce {
        enable = true;
        enable32Bit = true;
      };

      environment.sessionVariables.AMD_VULKAN_ICD = "RADV";

      # Take simpledrm out of the seat, or XWayland picks it and games cannot render.
      services.udev.extraRules = ''
        SUBSYSTEM=="drm", ENV{ID_PATH}=="*simple-framebuffer*", TAG-="master-of-seat", TAG-="seat"
      '';
    };
  };
}
