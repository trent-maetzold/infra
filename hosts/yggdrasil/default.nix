{
  imports = [
    ./boot.nix
    ./disk-config.nix
    ./persistence.nix
    ./vms/mimir.nix
  ];

  hardware.facter.reportPath = ./facter.json;
}
