{config, ...}: let
  inherit (config) flake;
in {
  flake.nixos.users.tm = {pkgs, ...}: {
    home-manager.users.tm.imports = [flake.homeModules.default flake.home.users.tm];

    programs.zsh.enable = true;
    services.openssh.enable = true;

    users.users.tm = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZMIGNBlZ+VX528eFfwCmEuN4oQCigRA+FPwADzixds tm@hive"];
    };
  };
}
