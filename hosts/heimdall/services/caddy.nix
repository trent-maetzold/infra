{
  config,
  lib,
  pkgs,
  ...
}: let
  # SNI matcher for TLS this edge doesn't terminate: every name outside
  # services.caddy.virtualHosts (hostName and serverAliases) goes to the ingress.
  # Without vhosts it is plain "tls"; an empty `not tls sni` is invalid.
  vhostNames = lib.concatMap (vhost: [vhost.hostName] ++ vhost.serverAliases) (lib.attrValues config.services.caddy.virtualHosts);

  passthrough =
    if vhostNames == []
    then "tls"
    else "not tls sni ${lib.concatStringsSep " " vhostNames}";
in {
  services.caddy = {
    enable = true;
    email = config.vars.acmeEmail;

    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.2.4"
        "github.com/mholt/caddy-l4@v0.1.2"
      ];

      hash = "sha256-AV85IaY63+Jkb3JadhQFZ6CeBkzbk9AWqY0/B3KP/4U=";
    };

    globalConfig = ''
      acme_dns cloudflare {file./var/lib/secrets/cf-dns-api-token}
      servers :443 {
        listener_wrappers {
          layer4 {
            @upstream ${passthrough}
            route @upstream {
              proxy ${config.vars.ingress}:443
            }
          }
          tls
        }
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
