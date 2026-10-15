{
  vars.hosts = {
    heimdall = {
      platform = "aarch64-linux";
      users = ["tm"];
      profiles = ["qemu-guest" "tailnet"];

      deployment = {
        targetHost = "hs.trkm.io";
        targetUser = "tm";
        buildOnTarget = true;

        keys = {
          cf-dns-api-token = {
            secret = "cf-dns-api-token.age";
            destDir = "/var/lib/secrets";
            user = "caddy";
            group = "caddy";
          };
          headplane-cookie-secret = {
            secret = "headplane-cookie-secret.age";
            destDir = "/var/lib/secrets";
            user = "headscale";
            group = "headscale";
          };
          ts-authkey.secret = "ts-authkey.age";
        };
      };
    };

    mimir.ssh.mimir.User = "root";

    muninn = {
      platform = "x86_64-linux";
      users = ["tm"];
      profiles = ["wsl"];
      lan.address = "10.10.10.125";
    };

    yggdrasil = {
      platform = "x86_64-linux";
      users = ["tm"];
      profiles = ["tailnet"];
      hostId = "6d8a7c3f";
      ingress = "100.64.0.3";

      deployment = {
        targetHost = "100.64.0.2";
        targetUser = "tm";

        keys = {
          cf-dns-api-token = {
            secret = "cf-dns-api-token.age";
            destDir = "/var/lib/secrets";
            user = "podman";
            group = "podman";
          };
          dockhand-env = {
            secret = "dockhand.env.age";
            destDir = "/var/lib/secrets";
            user = "podman";
            group = "podman";
          };
          ts-authkey.secret = "ts-authkey.age";
        };
      };

      lan = {
        address = "10.10.20.10";
        prefixLength = 24;
        interfaces = ["eno1" "eno2" "eno3" "eno4"];
        gateway = "10.10.20.1";
        nameservers = ["10.10.20.1" "1.1.1.1"];
      };

      ssh.yggdrasil-vnc = {
        HostName = "yggdrasil.ts.trkm.io";
        LocalForward = "5900 127.0.0.1:5900";
        ExitOnForwardFailure = "yes";
      };
    };
  };
}
