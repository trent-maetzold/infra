{
  programs.ssh.settings = {
    mimir = {
      HostName = "mimir.ts.trkm.io";
      User = "root";
    };

    yggdrasil-vnc = {
      HostName = "yggdrasil.ts.trkm.io";
      LocalForward = "5900 127.0.0.1:5900";
      ExitOnForwardFailure = "yes";
    };
  };
}
