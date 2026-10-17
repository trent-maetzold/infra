{
  imports = [
    ./boot.nix
    ./disk-config.nix
    ./services/quadlets.nix
    ./vms/mimir.nix
  ];

  hardware.facter.reportPath = ./facter.json;
}
