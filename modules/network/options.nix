# Where hosts are and how services are reached: read by traefik and headscale.
{lib, ...}: {
  options = {
    hosts = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options.ips.tailnet = lib.mkOption {type = lib.types.str;};
      });
      default = {};
      description = "Hosts by name, with their addresses.";
    };

    routes = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options = {
          hostname = lib.mkOption {type = lib.types.str;};

          public = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Reachable from the internet, not only the tailnet.";
          };

          dns = lib.mkOption {
            type = lib.types.enum ["tailnet" "cloudflare"];
            default = "tailnet";
            description = "Where the hostname's record lives.";
          };

          endpoint = {
            ip = lib.mkOption {type = lib.types.str;};
            port = lib.mkOption {type = lib.types.port;};

            scheme = lib.mkOption {
              type = lib.types.enum ["http" "https"];
              default = "http";
            };

            insecureSkipVerify = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Accept the endpoint's self-signed certificate.";
            };
          };
        };
      });
      default = {};
      description = "How each service is reached, by router name.";
    };
  };
}
