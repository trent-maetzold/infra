{
  flake.nixos.packages.btop = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [btop];
  };
}
