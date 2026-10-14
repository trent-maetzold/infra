{config, ...}: let
  out = {
    imports = [config.features.nixos.packages.admin];

    security.sudo.wheelNeedsPassword = false;
    services.openssh.settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
in {
  # Features
  features.nixos.base.core = out;

  # NixOS Modules
  flake.nixosModules.default.imports = [config.features.nixos.base.core];
}
