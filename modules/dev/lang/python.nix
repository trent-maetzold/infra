# Python with uv, ruff and ty; ty is also pi-lens's Python LSP.
{config, ...}: let
  modules.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [python3 python3Packages.debugpy ruff ty uv];
    programs.lazyvim.extras.lang.python.enable = true;

    home.file.".pi-lens/config.json".text = builtins.toJSON {
      lsp = {
        disabledServers = ["pyright" "python" "python-jedi"];

        servers.ty = {
          name = "ty";
          extensions = [".py" ".pyi"];
          command = ["ty" "server"];
        };
      };
    };
  };
in {
  # Flake Modules
  flake.modules.homeManager.lang-python = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.lang-python];
}
