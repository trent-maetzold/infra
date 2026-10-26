# trent: tm's workstation setup under the new name; features add the rest.
{config, ...}: let
  inherit (config.flake) homeModules;
in {
  flake.users.trent = config.flake.lib.makeUser {
    name = "trent";
    groups = ["wheel"];
    shell = "zsh";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZMIGNBlZ+VX528eFfwCmEuN4oQCigRA+FPwADzixds tm@hive";
    inherit (config.flake) hosts;

    git = {
      name = "Trent Maetzold";
      email = "trent@maetzold.co";
    };

    imports = [homeModules.trent];
  };

  flake.homeModules.trent.imports = [homeModules.globals homeModules.default homeModules.infra];
}
