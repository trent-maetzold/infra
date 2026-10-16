{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.efiSysMountPoint = "/boot/efi";
    };

    zfs.forceImportRoot = true;
  };
}
