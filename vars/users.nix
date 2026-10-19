{config, ...}: let
  inherit (config.flake) homeModules;
  inherit (config.flake.lib) makeUser;
  inherit (config.vars) global hosts;
  flake = "/home/tm/code/asgard";

  tm = imports:
    makeUser {
      name = "tm";
      groups = ["wheel"];
      shell = "zsh";
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZMIGNBlZ+VX528eFfwCmEuN4oQCigRA+FPwADzixds tm@hive";
      imports = [global ../home/tm] ++ imports;
      inherit flake hosts;

      git = {
        name = "Trent Maetzold";
        email = "trent@maetzold.co";
      };
    };
in {
  vars.users = {
    tm = tm [homeModules.default homeModules.data homeModules.infra];
    # Servers: shell, git and nix tooling only.
    tm-server = tm [homeModules.server];
  };

  flake.homeModules.tm = config.vars.users.tm.homeModule;

  perSystem = {system, ...}: {
    legacyPackages.homeConfigurations.tm = config.vars.users.tm.homeConfiguration system;
  };
}
