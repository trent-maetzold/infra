{
  config,
  inputs,
  ...
}: let
  inherit (config) flake;
in {
  flake.modules.nixos.tm = {pkgs, ...}: {
    nixpkgs.overlays = [flake.overlays.default inputs.colmena.overlays.default];

    home-manager.users.tm.imports = [flake.homeModules.default flake.modules.homeManager.tm];

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
