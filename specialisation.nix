{lib, ...}: {
  specialisation = {
    # eGPU only: disable the Intel iGPU and drive everything from the AMD eGPU.
    egpu.configuration = {
      system.nixos.tags = ["egpu"];

      boot = {
        initrd.kernelModules = ["amdgpu"];
        kernelParams = ["amdgpu.pcie_gen_cap=0x40000"];
        # Keep the Intel iGPU off so the AMD eGPU is the only graphics device.
        blacklistedKernelModules = ["i915" "xe"];
      };

      services.xserver.videoDrivers = lib.mkForce ["amdgpu"];

      hardware.graphics = lib.mkForce {
        enable = true;
        enable32Bit = true;
      };

      environment.sessionVariables.AMD_VULKAN_ICD = "RADV";
    };
  };
}
