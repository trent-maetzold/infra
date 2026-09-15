{lib, ...}: {
  programs.ssh = {
    enable = lib.mkDefault true;
    enableDefaultConfig = lib.mkDefault false;
    settings = lib.mkDefault {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
      };
    };
  };
}
