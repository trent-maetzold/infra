# `/` is a 2G tmpfs; state lives on /persist.
{config, ...}: let
  modules.nixos = {
    fileSystems."/persist".neededForBoot = true;

    disko.devices.nodev."/" = {
      fsType = "tmpfs";
      mountOptions = ["size=2G" "mode=755"];
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.disko-tmpfs-root = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.disko-tmpfs-root.imports = [config.flake.modules.nixos.disko-tmpfs-root];
  flake.nixosModules.frigg.imports = [config.flake.modules.nixos.disko-tmpfs-root];
  flake.nixosModules.thor.imports = [config.flake.modules.nixos.disko-tmpfs-root];
}
