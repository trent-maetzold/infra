{
  config,
  inputs,
  ...
}: let
  inherit (config) flake;
in {
  flake.homeModules.tm = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [flake.homeModules.default];

    home = {
      username = "tm";
      stateVersion = lib.mkDefault "26.11";
      packages = lib.mkAfter (with pkgs; [
        age
        colmena
        nixos-anywhere
        oci-cli
        opentofu
        ragenix
      ]);
    };

    programs = {
      git.settings.user = lib.mkIf config.programs.git.enable {
        name = "Trent Maetzold";
        email = "trent@maetzold.co";
      };
      nh.flake = lib.mkIf config.programs.nh.enable "/home/tm/code/asgard";
      pi-coding-agent.settings = lib.mkIf config.programs.pi-coding-agent.enable {
        defaultProvider = "opencode-go";
        defaultModel = "deepseek-v4.1-flash";
        defaultThinkingLevel = "max";
      };
      ssh.settings = lib.mkIf config.programs.ssh.enable {
        heimdall = {
          HostName = "heimdall.ts.trkm.io";
          User = "tm";
        };
        mimir = {
          HostName = "mimir.ts.trkm.io";
          User = "root";
        };
        muninn = {
          HostName = "muninn.ts.trkm.io";
          User = "tm";
        };
        muninn-lan = {
          HostName = "10.10.10.125";
          User = "tm";
        };
        yggdrasil = {
          HostName = "yggdrasil.ts.trkm.io";
          User = "tm";
        };
        yggdrasil-lan = {
          HostName = "10.10.20.10";
          User = "tm";
        };
        yggdrasil-vnc = {
          HostName = "yggdrasil.ts.trkm.io";
          User = "tm";
          LocalForward = "5900 127.0.0.1:5900";
          ExitOnForwardFailure = "yes";
        };
      };
    };
  };

  flake.homeConfigurations.tm = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      overlays = [flake.overlays.default inputs.colmena.overlays.default];
    };
    modules = [flake.homeModules.tm];
  };
}
