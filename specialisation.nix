{lib, ...}: {
  specialisation = {
    # eGPU only: disable the Intel iGPU and drive everything from the AMD eGPU.
    egpu.configuration = {
      system.nixos.tags = ["egpu"];

      boot = {
        initrd.kernelModules = ["amdgpu"];
        # module_blacklist on the cmdline keeps the kernel from loading the Intel DRM drivers at all.
        # The firmware framebuffer (simpledrm) is deliberately left in place: the root disk is
        # LUKS-encrypted, so the early-boot password prompt needs a working display, and the eGPU
        # is still powering up over Thunderbolt at that point. Dropping it makes the system unbootable.
        kernelParams = ["amdgpu.pcie_gen_cap=0x40000" "module_blacklist=i915,xe"];
        blacklistedKernelModules = ["i915" "xe"];
      };

      services.xserver.videoDrivers = lib.mkForce ["amdgpu"];

      hardware.graphics = lib.mkForce {
        enable = true;
        enable32Bit = true;
      };

      environment.sessionVariables.AMD_VULKAN_ICD = "RADV";

      # simpledrm (the firmware framebuffer, no render node) otherwise stays a seat
      # GPU; the graphical session then tries to accelerate XWayland on it, falls back
      # to software with no DRI3, and Vulkan games/UI can't present. Drop it from the
      # seat so only the AMD eGPU is used. Matched by driver path, not card number.
      services.udev.extraRules = ''
        SUBSYSTEM=="drm", ENV{ID_PATH}=="*simple-framebuffer*", TAG-="master-of-seat", TAG-="seat"
      '';
    };
  };
}
