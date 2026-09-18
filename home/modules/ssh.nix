{lib, ...}: {
  programs.ssh = {
    enable = lib.mkDefault true;
    enableDefaultConfig = lib.mkDefault false;
    settings = {
      "*" = {
        ForwardAgent = lib.mkDefault false;
        AddKeysToAgent = lib.mkDefault "no";
        Compression = lib.mkDefault false;
        ServerAliveInterval = lib.mkDefault 0;
        ServerAliveCountMax = lib.mkDefault 3;
        HashKnownHosts = lib.mkDefault false;
        UserKnownHostsFile = lib.mkDefault "~/.ssh/known_hosts";
      };
    };
  };
}
