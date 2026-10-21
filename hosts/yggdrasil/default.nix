{
  imports = [
    ./boot.nix
    ./disk-config.nix
    ./persist.nix
    ./vms/mimir.nix
  ];

  hardware.facter.reportPath = ./facter.json;
}
