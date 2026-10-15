# Turns `vars.users` into `nixosModules.<u>`, `homeModules.<u>` and
# `homeConfigurations`. Users get only profiles; the rest is glue from vars
# data that applies only where a feature already enabled the program.
{
  config,
  home-manager,
  lib,
  nixpkgs,
  ...
}: let
  inherit (config) vars;
  inherit (config.flake) homeModules nixosModules;

  hostSsh = name: host:
    lib.recursiveUpdate ({${name}.HostName = "${name}.${vars.tailnet.domain}";}
      // lib.optionalAttrs (host ? lan) {"${name}-lan".HostName = host.lan.address;}) (host.ssh or {});

  makeHome = name: {
    groups ? [],
    profiles ? [],
    publicKey ? null,
    ...
  } @ user: {
    imports =
      map (p: homeModules.${p}) profiles
      ++ [
        ({config, ...}: {
          home.username = name;

          programs = {
            git.settings.user = lib.mkIf (config.programs.git.enable && user ? git) {inherit (user.git) name email;};
            nh.flake = lib.mkIf (config.programs.nh.enable && lib.elem "wheel" groups) vars.nh.flake;
            ssh.settings = lib.mkIf (config.programs.ssh.enable && publicKey != null) (lib.concatMapAttrs hostSsh vars.hosts);
          };
        })
      ];
  };

  makeUser = name: {
    groups ? [],
    shell ? null,
    publicKey ? null,
    ...
  }: {
    config,
    pkgs,
    ...
  }: {
    home-manager.users.${name}.imports = [homeModules.${name}];

    users.users.${name} = {
      isNormalUser = true;
      extraGroups = groups;
      openssh.authorizedKeys.keys = lib.optional (publicKey != null) publicKey;
      shell = lib.mkIf (shell != null && config.programs.${shell}.enable) pkgs.${shell};
    };
  };
in {
  flake = {
    homeModules = lib.mapAttrs makeHome vars.users;
    nixosModules = lib.mapAttrs makeUser vars.users // {all.imports = map (u: nixosModules.${u}) (lib.attrNames vars.users);};

    homeConfigurations = lib.mapAttrs (name: user:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = user.platform;
          overlays = lib.attrValues config.flake.overlays;
        };
        modules = [homeModules.${name}];
      }) (lib.filterAttrs (_: user: user ? platform) vars.users);
  };
}
