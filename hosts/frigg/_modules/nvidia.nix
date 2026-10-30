# GTX 980 (Maxwell): the legacy 580 driver, which has no open kernel module.
{config, ...}: {
  services.xserver.videoDrivers = ["nvidia"];
  nixpkgs.config.allowUnfreePackages = ["nvidia-x11" "nvidia-kernel-modules" "nvidia-settings"];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    open = false;
  };
}
