{config, ...}: let
  inherit (config) vars;
  inherit (config.flake.lib) makeCaddyPassthrough;
  out = {
    config,
    pkgs,
    ...
  }: {
    services.caddy = {
      enable = true;
      email = vars.acmeEmail;
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
              @upstream ${makeCaddyPassthrough {virtualHosts = config.services.caddy.virtualHosts;}}
              route @upstream {
                proxy ${vars.hosts.yggdrasil.ingress}:443
              }
            }
            tls
          }
        }
      '';
    };
    networking.firewall.allowedTCPPorts = [80 443];
  };
in {
  # Features
  features.nixos.heimdall.caddy = out;

  # NixOS Modules
  flake.nixosModules.heimdall.imports = [config.features.nixos.heimdall.caddy];
}
