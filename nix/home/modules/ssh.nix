{
  config,
  lib,
  ...
}: let
  cfg = config.programs.ssh;
in {
  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enableDefaultConfig = lib.mkDefault false;
      settings."*" = {
        AddKeysToAgent = lib.mkDefault "no";
        Compression = lib.mkDefault false;
        ForwardAgent = lib.mkDefault false;
        HashKnownHosts = lib.mkDefault false;
        ServerAliveCountMax = lib.mkDefault 3;
        ServerAliveInterval = lib.mkDefault 0;
        UserKnownHostsFile = lib.mkDefault "~/.ssh/known_hosts";
      };
    };
  };
}
