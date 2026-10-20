{
  config,
  lib,
  ...
}: let
  endpoint = {config, ...}: {
    options = {
      host = lib.mkOption {type = lib.types.str;};
      port = lib.mkOption {type = lib.types.port;};

      url = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = "http://${config.host}:${toString config.port}";
      };
    };
  };

  route = {name, ...}: {
    options = {
      kind = lib.mkOption {type = lib.types.enum ["private" "tailnet" "public"];};
      endpoint = lib.mkOption {type = lib.types.submodule endpoint;};
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = name;
      };

      # Stripped before the endpoint, which gets it as X-Forwarded-Prefix.
      path = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };
  };

  features = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
in {
  options = {
    features = {
      home = lib.mkOption {
        type = features;
        default = {};
        description = "home-manager features, `<domain>.<feature>`.";
      };

      nixos = lib.mkOption {
        type = features;
        default = {};
        description = "NixOS features, `<domain>.<feature>`.";
      };
    };

    my = {
      endpoints = lib.mkOption {
        type = lib.types.lazyAttrsOf (lib.types.submodule endpoint);
        default = {};
        description = "Where each feature listens by default, `<name>`; loopback unless a consumer says otherwise.";
      };

      services = lib.mkOption {
        type = lib.types.lazyAttrsOf (lib.types.submodule {
          options = {
            host = lib.mkOption {
              type = lib.types.str;
              description = "Name of the host (in `vars.hosts`) that runs the service.";
            };

            modules = lib.mkOption {
              type = lib.types.listOf lib.types.deferredModule;
              default = [];
              description = "NixOS modules the host imports to run the service.";
            };

            routes = lib.mkOption {
              type = lib.types.lazyAttrsOf (lib.types.submodule route);
              default = {};
              description = "How the service is reached, `<name>`, made with `makePrivateRoute`, `makeTailnetRoute` and `makePublicRoute`.";
            };
          };
        });
        default = {};
        description = "Services, `<service>`: opinionated, they choose their host, routes and storage.";
      };

      routes = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        readOnly = true;
        description = "Every service's routes by name, with the `host` serving each.";
      };
    };

    vars = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = {};
      description = "This flake's inventory: `global` module, makeHost results in `hosts`, makeUser results in `users`.";
    };

    flake.lib = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = {};
      description = "Public helper functions.";
    };
  };

  config.my.routes = lib.concatMapAttrs (_: service: lib.mapAttrs (_: route: route // {inherit (service) host;}) service.routes) config.my.services;
}
