{
  self,
  pkgs,
  system,
}: let
  inherit (pkgs) lib;
  overlayCount = overlays: lib.count (overlay: (overlay pkgs pkgs) ? tredis) overlays;
  consumerOverlay = _: prev: {nodejs = prev.nodejs_22;};
  host = {
    system.stateVersion = "26.05";
    boot.loader.grub.enable = false;
    fileSystems."/" = {
      device = "/dev/disk/by-label/asgard-check";
      fsType = "ext4";
    };
  };
  home = {
    home = {
      username = "asgard-check";
      homeDirectory = "/home/asgard-check";
      stateVersion = "26.05";
    };
  };

  nixosCatalog = self.lib.nixosSystem {
    inherit system;
    modules = [self.nixosModules.default host];
  };
  nixos = self.lib.nixosSystem {
    inherit system;
    modules = [
      self.nixosModules.defaults
      self.nixosModules.home-manager
      host
      {
        users.users.asgard-check.isNormalUser = true;
        home-manager.users.asgard-check = {
          imports = [self.homeManagerModules.defaults];
          home.stateVersion = "26.05";
        };
      }
    ];
  };
  localHome = nixos.extendModules {modules = [{home-manager.useGlobalPkgs = false;}];};
  homeCatalog = self.lib.mkHome {
    inherit system;
    modules = [self.homeManagerModules.default home];
  };
  homeManager = self.lib.mkHome {
    inherit system;
    modules = [self.homeManagerModules.development home];
  };
  overrides = self.lib.mkHome {
    inherit system;
    modules = [
      self.homeManagerModules.development
      home
      {
        home.packages = [pkgs.hello];
        nixpkgs.overlays = [consumerOverlay];
        programs = {
          git.enable = false;
          lazyvim.enable = false;
          ssh.settings."*".ServerAliveInterval = 30;
        };
        languages.nix.enable = false;
      }
    ];
  };
  overrideHost = self.lib.nixosSystem {
    inherit system;
    modules = [
      self.nixosModules.defaults
      host
      {
        environment.systemPackages = [pkgs.hello];
        nixpkgs.overlays = [consumerOverlay];
        i18n.defaultLocale = "de_DE.UTF-8";
        nix.settings.trusted-users = ["asgard-check"];
      }
    ];
  };

  migration = import ./migration.nix {inherit self pkgs system;};
  report =
    migration.report
    // {
      catalog-nixos =
        !nixosCatalog.config.asgard.enable
        && !nixosCatalog.config.services.headscale.enable
        && !nixosCatalog.config.services.headplane.enable
        && !nixosCatalog.config.services.llama-swap.enable
        && !nixosCatalog.config.wsl.enable
        && builtins.length nixosCatalog.config.nixpkgs.overlays == 1;
      catalog-home =
        !homeCatalog.config.asgard.enable
        && !homeCatalog.config.programs.agents.enable
        && !homeCatalog.config.programs.pi-coding-agent.enable
        && !homeCatalog.config.programs.lazyvim.enable
        && !homeCatalog.config.programs.distrobox.enable
        && !homeCatalog.config.services.podman.enable
        && lib.all (cfg: !cfg.enable) (lib.attrValues homeCatalog.config.languages);
      overrides-home =
        !overrides.config.programs.git.enable
        && !overrides.config.programs.lazyvim.enable
        && !overrides.config.languages.nix.enable
        && overrides.config.programs.ssh.settings."*".data.ServerAliveInterval == 30
        && lib.elem pkgs.hello overrides.config.home.packages
        && lib.elem pkgs.just overrides.config.home.packages
        && overrides.pkgs.nodejs.version == pkgs.nodejs_22.version;
      overrides-nixos =
        overrideHost.config.i18n.defaultLocale
        == "de_DE.UTF-8"
        && lib.elem "@wheel" overrideHost.config.nix.settings.trusted-users
        && lib.elem "asgard-check" overrideHost.config.nix.settings.trusted-users
        && lib.elem pkgs.hello overrideHost.config.environment.systemPackages
        && lib.elem pkgs.just overrideHost.config.environment.systemPackages
        && overrideHost.pkgs.nodejs.version == pkgs.nodejs_22.version
        && overlayCount overrideHost.config.nixpkgs.overlays == 1
        && builtins.length nixos.config.home-manager.sharedModules == 1;
      local-home-packages = overlayCount localHome.config.home-manager.users.asgard-check.nixpkgs.overlays == 1;
      integration =
        builtins.deepSeq [
          nixosCatalog.config.system.build.toplevel.drvPath
          nixos.config.system.build.toplevel.drvPath
          overrideHost.config.system.build.toplevel.drvPath
          localHome.config.system.build.toplevel.drvPath
          homeCatalog.activationPackage.drvPath
          homeManager.activationPackage.drvPath
          overrides.activationPackage.drvPath
        ]
        true;
    };
in {
  inherit nixos homeManager report;
  passed =
    lib.assertMsg (lib.all (value: value) (lib.attrValues report))
    "Asgard module integration or consumer override checks failed.";
}
