# tm: the workstation user; tm-server is the same user with server tooling only.
{config, ...}: let
  inherit (config.flake) homeModules;
  inherit (config.vars) global;

  tm = imports:
    config.flake.lib.makeUser {
      name = "tm";
      groups = ["wheel"];
      shell = "zsh";
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZMIGNBlZ+VX528eFfwCmEuN4oQCigRA+FPwADzixds tm@hive";
      flake = "/home/tm/code/asgard";
      inherit (config.flake) hosts;

      git = {
        name = "Trent Maetzold";
        email = "trent@maetzold.co";
      };

      imports = [global] ++ imports;
    };
in {
  flake.users = {
    tm = tm [homeModules.default homeModules.data homeModules.infra];
    # Servers: shell, git and nix tooling only.
    tm-server = tm [homeModules.server];
  };

  flake.homeModules.tm = config.flake.users.tm.homeModule;

  perSystem = {system, ...}: {
    legacyPackages.homeConfigurations.tm = config.flake.users.tm.homeConfiguration system;
  };
}
