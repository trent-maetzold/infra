{
  flake.nixos.packages.admin = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [curl gcc git gnumake just openssh openssl pkg-config tree unzip wget];
  };
  flake.home.packages.admin = {pkgs, ...}: {
    home.packages = with pkgs; [curl gcc git gnumake just openssh openssl pkg-config tree unzip wget];
  };
}
