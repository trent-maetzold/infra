{
  config,
  inputs,
  ...
}: let
  inherit (config) flake;
in {
  flake.home.users.tm = {
    home.username = "tm";

    programs = {
      git.settings.user = {
        name = "Trent Maetzold";
        email = "trent@maetzold.co";
      };
      nh.flake = "/home/tm/code/asgard";
      pi-coding-agent.settings = {
        defaultProvider = "opencode-go";
        defaultModel = "deepseek-v4.1-flash";
        defaultThinkingLevel = "max";
      };
      ssh.settings = {
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
      overlays = [flake.overlays.default];
    };
    modules = [
      flake.homeModules.default
      flake.home.users.tm
      {home.stateVersion = "26.11";}
    ];
  };
}
