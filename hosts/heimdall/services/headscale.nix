{
  config,
  lib,
  ...
}: let
  inherit (config) vars;
  loginHost = lib.removePrefix "https://" vars.tailnet.loginServer;
in {
  services = {
    headscale = {
      enable = true;

      settings = {
        server_url = vars.tailnet.loginServer;

        dns = {
          magic_dns = true;
          base_domain = vars.tailnet.domain;
          nameservers.global = ["1.1.1.1" "9.9.9.9"];
        };
      };
    };

    headplane = {
      enable = true;

      settings = {
        server = {
          base_url = "${vars.tailnet.loginServer}/admin";
          cookie_secret_path = "/var/lib/secrets/headplane-cookie-secret";
        };

        headscale.config_path = config.services.headscale.configFile;
      };
    };

    caddy.virtualHosts.${loginHost}.extraConfig = ''
      handle /admin* {
        reverse_proxy 127.0.0.1:${toString config.services.headplane.settings.server.port}
      }
      handle {
        reverse_proxy 127.0.0.1:${toString config.services.headscale.port}
      }
    '';
  };
}
