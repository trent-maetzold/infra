{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };
      efi.canTouchEfiVariables = false;
    };
    growPartition = true;
    kernelParams = ["net.ifnames=0"];
  };
}
