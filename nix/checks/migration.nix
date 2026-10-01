{
  self,
  pkgs,
  system,
}: let
  inherit (pkgs) lib;
  home = {
    home = {
      username = "asgard-check";
      homeDirectory = "/home/asgard-check";
      stateVersion = "26.05";
    };
  };
  credentialHome = enable: module:
    self.lib.mkHome {
      inherit system;
      modules = [
        self.homeManagerModules.default
        home
        {
          programs.pi-coding-agent = {
            inherit enable;
            package = null;
          };
        }
        module
      ];
    };
  disabled = credentialHome false ({config, ...}: {
    programs.pi-coding-agent = {
      encryptedApiKeys.OPENCODE_API_KEY = builtins.toPath "/missing/asgard-test-credential.age";
      apiKeyFiles.OPENROUTER_API_KEY = config.age.secrets.missing.path;
    };
  });
  absent = credentialHome true {};
  encrypted = credentialHome true {
    programs.pi-coding-agent.encryptedApiKeys = {
      OPENCODE_API_KEY = ./fixtures/credential.age;
      OPENROUTER_API_KEY = null;
    };
  };
  runtime = credentialHome true {
    programs.pi-coding-agent.apiKeyFiles.OPENROUTER_API_KEY = "/run/secrets/synthetic key";
  };
  replaced = credentialHome true {
    programs.pi-coding-agent = {
      encryptedApiKeys.OPENCODE_API_KEY = null;
      apiKeyFiles.OPENCODE_API_KEY = "/run/secrets/replacement";
    };
  };
  invalid = credentialHome true {programs.pi-coding-agent.apiKeyFiles."BAD;NAME" = "/run/secrets/key";};
  missing = credentialHome true {programs.pi-coding-agent.encryptedApiKeys.OPENCODE_API_KEY = builtins.toPath "/missing/asgard-test-credential.age";};
  contributed = cfg: lib.any (definition: lib.hasSuffix "/agents/pi/credentials.nix" definition.file) cfg.options.home.sessionVariablesExtra.definitionsWithLocations;
  modules = self.lib.nixosSystem {
    inherit system;
    modules = [
      self.nixosModules.defaults
      self.nixosModules.disk
      self.nixosModules.quadlet
      self.nixosModules.secrets
      {
        system.stateVersion = "26.05";
        boot.loader.grub.enable = false;
        fileSystems."/" = {
          device = "/dev/disk/by-label/asgard-check";
          fsType = "ext4";
        };
      }
    ];
  };
  key = self.lib.makeDeploymentKey {
    secretFile = ./fixtures/credential.age;
    identityFile = "/run/controller keys/identity";
    destDir = "/run/keys";
    user = "example-service";
    group = "example-service";
  };
in {
  report = {
    credentials-disabled = disabled.config.age.secrets == {} && !contributed disabled;
    credentials-absent = absent.config.age.secrets == {} && !contributed absent;
    credentials-encrypted = lib.attrNames encrypted.config.age.secrets == ["pi-OPENCODE_API_KEY"] && contributed encrypted && !lib.hasInfix "OPENROUTER" encrypted.config.home.sessionVariablesExtra;
    credentials-runtime = runtime.config.age.secrets == {} && contributed runtime && lib.hasInfix "'/run/secrets/synthetic key'" runtime.config.home.sessionVariablesExtra;
    credentials-replaced = replaced.config.age.secrets == {} && contributed replaced;
    credentials-invalid-name = !(builtins.tryEval invalid.activationPackage.drvPath).success;
    credentials-invalid-source = !(builtins.tryEval missing.activationPackage.drvPath).success;
    dependency-closure = modules.options ? disko.zfs.enable && modules.options ? virtualisation.quadlet.enable && modules.options ? age.secrets && !modules.config.virtualisation.podman.enable && !modules.config.disko.zfs.enable;
    deployment-key = lib.take 4 key.keyCommand == ["age" "--decrypt" "--identity" "/run/controller keys/identity"] && key.destDir == "/run/keys" && key.user == "example-service" && key.group == "example-service";
    migration-integration =
      builtins.deepSeq [
        disabled.activationPackage.drvPath
        absent.activationPackage.drvPath
        encrypted.activationPackage.drvPath
        runtime.activationPackage.drvPath
        replaced.activationPackage.drvPath
        modules.config.system.build.toplevel.drvPath
      ]
      true;
  };
  environment = encrypted.config.home.sessionVariablesExtra;
}
