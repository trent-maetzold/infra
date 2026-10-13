{
  flake.nixos.heimdall.headscale = {config, ...}: {
    services = {
      headscale = {
        enable = true;
        settings = {
          server_url = "https://hs.trkm.io";
          dns = {
            magic_dns = true;
            base_domain = "ts.trkm.io";
            nameservers.global = ["1.1.1.1" "9.9.9.9"];
          };
        };
      };
      headplane = {
        enable = true;
        settings = {
          server = {
            base_url = "https://hs.trkm.io/admin";
            cookie_secret_path = "/var/lib/secrets/headplane-cookie-secret";
          };
          headscale.config_path = config.services.headscale.configFile;
        };
      };
      caddy.virtualHosts."hs.trkm.io".extraConfig = ''
        handle /admin* {
          reverse_proxy 127.0.0.1:${toString config.services.headplane.settings.server.port}
        }
        handle {
          reverse_proxy 127.0.0.1:${toString config.services.headscale.port}
        }
      '';
    };
  };
}
