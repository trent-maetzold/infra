# trent: tm's workstation setup under the new name, plus NVIDIA monitors.
{config, ...}: let
  inherit (config.flake) homeModules modules;
  inherit (config.vars) global;
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

    imports = [global homeModules.default homeModules.data homeModules.infra modules.homeManager.nvidia-tools];
  };
}
