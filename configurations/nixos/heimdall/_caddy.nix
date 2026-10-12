{
  config,
  lib,
  pkgs,
  ...
}: let
  makeCaddyPassthrough = import ./_make-caddy-passthrough.nix {inherit lib;};
in {
  services.caddy = {
    enable = true;
    email = "tkm89@proton.me";
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.2.4"
        "github.com/mholt/caddy-l4@v0.1.2"
      ];
      hash = "sha256-EWpo+POYSfxsAE4W4T9ngK+n1bmJPzLS8A1+JGvoJvE=";
    };
    globalConfig = ''
      acme_dns cloudflare {file./var/lib/secrets/cf-dns-api-token}
      servers :443 {
        listener_wrappers {
          layer4 {
            @upstream ${makeCaddyPassthrough {virtualHosts = config.services.caddy.virtualHosts;}}
            route @upstream {
              proxy 100.64.0.3:443
            }
          }
          tls
        }
      }
    '';
  };
}
