{config, ...}: {
  flake.nixos.base.core = {
    imports = [config.flake.nixos.packages.admin];

    security.sudo.wheelNeedsPassword = false;
    services.openssh.settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  flake.nixosModules.default.imports = [config.flake.nixos.base.core];
}
