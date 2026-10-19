{
  boot = {
    # The OCI image's layout: GRUB as the removable EFI loader on /boot.
    loader.grub = {
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
      configurationLimit = 3;
    };

    growPartition = true;
    kernelParams = ["net.ifnames=0"];
  };
}
