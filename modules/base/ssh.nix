{config, ...}: let
  modules.home = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        AddKeysToAgent = "no";
        Compression = false;
        ForwardAgent = false;
        HashKnownHosts = false;
        ServerAliveCountMax = 3;
        ServerAliveInterval = 0;
        UserKnownHostsFile = "~/.ssh/known_hosts";
      };
    };
  };

  modules.nixos = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
in {
  # Flake Modules
  flake.modules.home.ssh = modules.home;
  flake.modules.nixos.ssh = modules.nixos;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.home.ssh];
  flake.homeModules.server.imports = [config.flake.modules.home.ssh];

  # NixOS Configuration Modules
  flake.nixosModules.default.imports = [config.flake.modules.nixos.ssh];
}
