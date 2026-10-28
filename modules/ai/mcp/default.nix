# Bifrost on loopback fronts every MCP server: Context7, DeepWiki, skillport.
# Agents get it as their one MCP server, `gateway`; secrets and tool policy stay
# outside their jails. Add servers to `flake.programs.mcp.servers`.
{
  awesome-copilot,
  bifrost,
  config,
  ...
}: let
  port = 18744;
  stateDir = "/var/lib/bifrost";

  # This flake's additions, merged over the feature's defaults.
  extraServers = config.flake.programs.mcp.servers;

  modules.nixos = {
    config,
    lib,
    pkgs,
    ...
  }: let
    skills = pkgs.linkFarm "skillport-skills" {git-commit = "${awesome-copilot}/skills/git-commit";};

    defaults = {
      context7.url = "https://mcp.context7.com/mcp";
      deepwiki.url = "https://mcp.deepwiki.com/mcp";
      skillport = {
        command = lib.getExe pkgs.skillport-mcp;
        args = [];
        env = {
          SKILLPORT_SKILLS_DIR = "${skills}";
          SKILLPORT_DB_PATH = "${stateDir}/skillport/skills.lancedb";
          SKILLPORT_META_DIR = "${stateDir}/skillport";
        };
      };
    };

    servers = defaults // extraServers;
    makeClient = import ../_lib/make-bifrost-client.nix {inherit lib pkgs;};
  in {
    imports = [bifrost.nixosModules.bifrost];

    services.bifrost = {
      enable = true;
      package = bifrost.packages.${pkgs.stdenv.hostPlatform.system}.default;
      host = "127.0.0.1";
      inherit port stateDir;

      environment = lib.concatMapAttrs (_: server: lib.filterAttrs (_: builtins.isString) (server.env or {})) servers;

      settings.mcp.client_configs = lib.mapAttrsToList makeClient servers;
    };
  };

  modules.homeManager = _: {
    programs.mcp = {
      enable = true;
      servers.gateway.url = "http://127.0.0.1:${toString port}/mcp";
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.mcp = modules.nixos;
  flake.modules.homeManager.mcp = modules.homeManager;

  # NixOS Configuration Modules
  flake.nixosModules.default.imports = [config.flake.modules.nixos.mcp];

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.mcp];
}
