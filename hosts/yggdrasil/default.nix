{
  imports = [
    ./boot.nix
    ./disk-config.nix
    ./persist.nix
    ./services/dockhand.nix
    ./services/traefik.nix
    ./vms/mimir.nix
  ];

  hardware.facter.reportPath = ./facter.json;
}
