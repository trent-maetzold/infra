# Agents reach MCP servers only through `mcp-<server> <tool> key=value` and
# `mcp-list`: mcporter with `mcp.servers` baked in, itself off PATH. The skills
# server (skillz) serves ~/.agents/skills as tools.
{config, ...}: let
  out = {
    config,
    lib,
    pkgs,
    ...
  }: let
    json = pkgs.formats.json {};
    # `imports = []` stops mcporter merging Claude, Codex and editor configs.
    settings = json.generate "mcporter.json" {
      mcpServers = config.mcp.servers;
      imports = [];
    };
    wrap = name: flags: "makeWrapper ${lib.getExe pkgs.llm-agents.mcporter} $out/bin/${name} --set MCPORTER_CONFIG ${settings} --add-flags '${flags}'";
  in {
    options.mcp.servers = lib.mkOption {type = lib.types.attrsOf json.type;};

    config = {
      mcp.servers = {
        context7.url = "https://mcp.context7.com/mcp";
        deepwiki.url = "https://mcp.deepwiki.com/mcp";

        skills = {
          command = lib.getExe pkgs.skillz;
          args = ["${config.home.homeDirectory}/.agents/skills"];
        };
      };

      home.packages = [
        (pkgs.runCommand "mcp-servers" {nativeBuildInputs = [pkgs.makeWrapper];}
          (lib.concatLines ([(wrap "mcp-list" "list")] ++ map (s: wrap "mcp-${s}" "call ${s}") (lib.attrNames config.mcp.servers))))
      ];

      agents.md.tools = ["- MCP: `mcp-list [server] --schema` shows servers, tools and arguments; `mcp-<server> <tool> key=value` (e.g. `mcp-deepwiki ask_wiki_question repoName=o/r question=...`) calls one."];
    };
  };
in {
  # Features
  features.home.ai.mcp = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.mcp];
}
