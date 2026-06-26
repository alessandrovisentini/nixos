{lib, ...}: {
  specialisation = {
    # eGPU only: disable the Intel iGPU and drive everything from the AMD eGPU.
    egpu.configuration = {
      system.nixos.tags = ["egpu"];

      boot = {
        initrd.kernelModules = ["amdgpu"];
        # module_blacklist on the cmdline keeps the kernel from loading the Intel DRM drivers at all
        kernelParams = ["amdgpu.pcie_gen_cap=0x40000" "module_blacklist=i915,xe"];
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
