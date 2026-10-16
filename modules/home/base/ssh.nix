{config, ...}: let
  out = {...}: {
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
in {
  # Features
  features.home.base.ssh = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.base.ssh];
}
