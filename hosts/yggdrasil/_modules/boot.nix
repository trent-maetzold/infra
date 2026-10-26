{
  # Headless: a failed unit must not isolate into a locked emergency shell.
  systemd.enableEmergencyMode = false;

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };

      efi.efiSysMountPoint = "/boot/efi";
    };

    zfs.forceImportRoot = true;
  };
}
