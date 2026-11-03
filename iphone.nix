{pkgs, ...}: {
  # iPhone USB
  # Pairs with the phone, without it USB tethering never comes up.
  services.usbmuxd.enable = true;

  environment.systemPackages = with pkgs; [
    libimobiledevice
  ];
}
