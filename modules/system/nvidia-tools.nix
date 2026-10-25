# NVIDIA GPU monitors for the terminal.
{
  # Flake Modules
  flake.modules.homeManager.nvidia-tools = {pkgs, ...}: {
    home.packages = with pkgs; [nvtopPackages.nvidia nvitop python3Packages.gpustat];
  };
}
