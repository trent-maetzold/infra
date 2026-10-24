# Paseo's exports in the shape the rest of this flake reads (`my.endpoints`,
# `my.services`), and the host inventory in the shape paseo reads. Delete it in
# the next refactor, when every module is written like paseo.nix.
{
  config,
  lib,
  ...
}: let
  name = "paseo";
  host = "yggdrasil";
  inherit (config.routes) paseo;
in {
  options = {
    hosts = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.submodule {options.ips.tailnet = lib.mkOption {type = lib.types.str;};});
      default = {};
    };

    routes = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = {};
    };
  };

  config = {
    hosts = lib.mapAttrs (_: host: {ips.tailnet = host.tailnetIp;}) (lib.filterAttrs (_: host: host.tailnetIp != null) config.vars.hosts);

    my.endpoints.${name} = {
      host = paseo.endpoint.ip;
      inherit (paseo.endpoint) port;
    };

    # `flake.nixosModules.<host>` cannot be imported into that host's own module
    # (`vars` builds it from the same module), so the instance paseo declares is
    # rebuilt from `routes.<name>`. `routes.<name>` is served at `<name>.<tailnet
    # domain>`, the hostname paseo declares for itself.
    my.services.${name} = {
      inherit host;

      modules = [
        config.flake.modules.nixos.${name}
        {
          services.paseo = {
            hostnames = [paseo.hostname];
            listenAddress = paseo.endpoint.ip;
            inherit (paseo.endpoint) port;
          };
        }
      ];

      routes.${name} = config.flake.lib.makeTailnetRoute config.my.endpoints.${name};
    };
  };
}
