{config, ...}: let
  home = {config, ...}: {
    home = {
      homeDirectory = "/home/${config.home.username}";
      sessionPath = ["${config.home.homeDirectory}/.local/bin"];
    };
  };

  nixos = {
    security.sudo.wheelNeedsPassword = false;

    services.openssh = {
      enable = true;

      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
in {
  # Modules
  my.modules.base.core = {inherit home nixos;};

  # Profiles
  flake = {
    homeModules.default.imports = [config.my.modules.base.core.home];
    nixosModules.default.imports = [config.my.modules.base.core.nixos];
  };
}
