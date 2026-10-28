# autolith, a live, self-modifying Common Lisp agent, from its own flake.
{
  config,
  jail-nix,
  ...
}: let
  inherit (config.flake.lib) makeAgentJail;

  modules.homeManager = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.programs.mcp.servers.gateway) url;
    jail = makeAgentJail {inherit config jail-nix pkgs;};
  in {
    home.packages = [
      (jail "autolith" pkgs.autolith {
        state = with config.xdg; ["${configHome}/autolith" "${dataHome}/autolith" "${stateHome}/autolith" "${cacheHome}/autolith"];
      })
    ];

    xdg.configFile."autolith/mcp.sexp".text = ''(:version 1 :servers ((:name "gateway" :transport (:type :http :url "${url}"))))'';

    agents.md.coding-agents = [
      "- `autolith`: Common Lisp agent that edits its own running image. Headless: `autolith --permissions auto run-job --input <job.sexp> --output <result.sexp>`; the job file names the role, prompt and output contract."
    ];
  };
in {
  # Flake Modules
  flake.modules.homeManager.autolith = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.autolith];
}
