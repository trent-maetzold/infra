# autolith, a live, self-modifying Common Lisp agent, from its own flake.
{config, ...}: let
  modules.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    mcp = import ./_lib/make-mcp-sexp.nix {inherit lib pkgs;} config.programs.mcp.servers;
  in {
    home.packages = [pkgs.autolith];

    xdg.configFile."autolith/mcp.sexp".text = mcp;

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
