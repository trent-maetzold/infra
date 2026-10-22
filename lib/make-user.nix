# A user. `imports` carries the profiles (`asgard.homeModules.*`) and plain
# home modules. The rest is glue that applies only where a feature already
# enabled the program; `hosts` (makeHost results) become ssh client entries.
{
  config,
  home-manager,
  lib,
  nixpkgs,
  ...
}: let
  inherit (config) my;
in {
  flake.lib.makeUser = {
    name,
    imports ? [],
    groups ? [],
    shell ? null,
    publicKey ? null,
    git ? null,
    flake ? null,
    hosts ? {},
  }: let
    homeModule = {config, ...}: {
      # The same handoff as a host: a user module takes `my` as an argument.
      _module.args.my = my;

      inherit imports;

      home.username = name;

      programs = {
        git.settings.user = lib.mkIf (config.programs.git.enable && git != null) git;
        nh.flake = lib.mkIf (config.programs.nh.enable && flake != null) flake;
        ssh.settings = lib.mkIf config.programs.ssh.enable (lib.concatMapAttrs (_: host: lib.mapAttrs (_: s: {User = name;} // s) host.ssh) hosts);
      };
    };
  in {
    inherit name homeModule;

    nixosModule = {pkgs, ...}: {
      imports = [home-manager.nixosModules.home-manager];

      home-manager.users.${name} = homeModule;

      # A login shell needs its NixOS module for /etc/shells and the system profile.
      programs = lib.optionalAttrs (shell != null) {${shell}.enable = true;};

      users.users.${name} = {
        isNormalUser = true;
        extraGroups = groups;
        openssh.authorizedKeys.keys = lib.optional (publicKey != null) publicKey;
        shell = lib.mkIf (shell != null) pkgs.${shell};
      };
    };

    homeConfiguration = system:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          overlays = lib.attrValues config.flake.overlays;
        };

        modules = [homeModule];
      };
  };
}
