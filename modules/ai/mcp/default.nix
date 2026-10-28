# agentgateway on loopback fronts every MCP server: Context7, DeepWiki, skillport.
# Agents get it as their one MCP server, `gateway`; secrets and tool policy stay
# outside their jails. Add servers to `agentgateway.targets`.
{
  awesome-copilot,
  config,
  ...
}: let
  modules.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    yaml = pkgs.formats.yaml {};
    port = 18744;
    skills = pkgs.linkFarm "skillport-skills" {git-commit = "${awesome-copilot}/skills/git-commit";};
  in {
    agentgateway.targets = [
      {
        name = "context7";
        mcp.host = "https://mcp.context7.com/mcp";
      }
      {
        name = "deepwiki";
        mcp.host = "https://mcp.deepwiki.com/mcp";
      }
      {
        name = "skillport";
        stdio = {
          cmd = lib.getExe pkgs.skillport-mcp;
          env = {
            SKILLPORT_SKILLS_DIR = "${skills}";
            SKILLPORT_DB_PATH = "${config.xdg.cacheHome}/skillport/skills.lancedb";
            SKILLPORT_META_DIR = "${config.xdg.stateHome}/skillport";
          };
        };
      }
    ];

    programs.mcp = {
      enable = true;
      servers.gateway.url = "http://127.0.0.1:${toString port}/mcp";
    };

    xdg.configFile."agentgateway/config.yaml".source = yaml.generate "agentgateway.yaml" {
      config = {
        statsAddr = "127.0.0.1:15020";
        readinessAddr = "127.0.0.1:15021";
      };
      gateways.default = {
        inherit port;
        bindAddress = "127.0.0.1";
      };
      routes = [{backends = [{mcp.targets = config.agentgateway.targets;}];}];
    };

    systemd.user.services.agentgateway = {
      Unit.Description = "agentgateway MCP gateway";
      Service.ExecStart = "${lib.getExe pkgs.agentgateway} -f ${config.xdg.configHome}/agentgateway/config.yaml";
      Install.WantedBy = ["default.target"];
    };
  };
in {
  # Flake Modules
  flake.modules.homeManager.mcp = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.mcp];
}
