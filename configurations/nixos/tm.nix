{config, ...}: let
  inherit (config) features flake;
  out = {pkgs, ...}: {
    home-manager.users.tm.imports = [flake.homeModules.default features.home.users.tm];

    programs.zsh.enable = true;
    services.openssh.enable = true;

    users.users.tm = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZMIGNBlZ+VX528eFfwCmEuN4oQCigRA+FPwADzixds tm@hive"];
    };
  };
in {
  # Features
  features.nixos.users.tm = out;
}
