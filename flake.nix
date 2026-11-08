# The map of the repo: inputs, what is imported, and the infra every host, user and service reads.
{
  inputs = {
    # Base
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Flake structure
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";

    # Homes
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.flake-parts.flakeModules.modules
        inputs.home-manager.flakeModules.home-manager
        (inputs.import-tree [./nix/modules ./nix/lib ./nix/checks])
        # Every host, user and NixOS service directory, listed by hand: this list is the inventory.
      ];

      systems = ["x86_64-linux" "aarch64-linux"];

      # treefmt walks the tree; bare alejandra would read stdin, since nix fmt passes no paths.
      perSystem = {pkgs, ...}: {
        formatter = pkgs.treefmt.withConfig {
          settings.formatter.alejandra = {
            command = pkgs.lib.getExe pkgs.alejandra;
            includes = ["*.nix"];
          };
        };
      };

      _module.args.infra = {
        domain = "trkm.io";
        acmeEmail = "tkm89@proton.me";
        timeZone = "America/Chicago";

        tailnet = {
          loginServer = "https://hs.trkm.io";
          domain = "ts.trkm.io";
          subnet = "100.64.0.0/10";
        };

        machines = {
          muninn = {
            lan.address = "10.10.10.125";
            ssh.hostname = "muninn.ts.trkm.io";
          };

          frigg.ssh = {
            hostname = "frigg.ts.trkm.io";
            user = "trent";
          };

          thor.ssh = {
            hostname = "thor.ts.trkm.io";
            user = "trent";
          };

          heimdall = {
            tailnet = "100.64.0.6";
            ssh.hostname = "heimdall.ts.trkm.io";
          };

          yggdrasil = {
            tailnet = "100.64.0.2";
            ssh.hostname = "yggdrasil.ts.trkm.io";

            lan = {
              address = "10.10.20.10";
              prefixLength = 24;
              gateway = "10.10.20.1";
              nameservers = ["10.10.20.1" "1.1.1.1"];
            };
          };

          yggdrasil-bmc = {
            lan.address = "10.10.20.154";

            ssh = {
              hostname = "bmc.yggdrasil.ts.trkm.io";
              user = "root";
            };
          };

          mimir.ssh = {
            hostname = "mimir.ts.trkm.io";
            user = "root";
          };
        };

        routes = {};
        dns = [];
      };
    };
}
