# tm: the workstation user; tm-server is the same user with server tooling only.
{config, ...}: let
  inherit (config.flake) homeModules;

  tm = imports:
    config.flake.lib.makeUser {
      name = "tm";
      groups = ["wheel"];
      shell = "zsh";
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZMIGNBlZ+VX528eFfwCmEuN4oQCigRA+FPwADzixds tm@hive";
      inherit (config.flake) hosts;
      specialArgs = config.vars;

      git = {
        name = "Trent Maetzold";
        email = "trent@maetzold.co";
      };

      inherit imports;
    };
in {
  flake.users = {
    tm = tm [homeModules.tm];
    # Servers: shell, git and nix tooling only.
    tm-server = tm [homeModules.default-slim];
  };

  flake.homeModules.tm.imports = [
    homeModules.default
    homeModules.infra
  ];

  perSystem = {system, ...}: {
    legacyPackages.homeConfigurations.tm = config.flake.users.tm.homeConfiguration system;
  };
}
