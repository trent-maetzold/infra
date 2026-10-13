{config, ...}: let
  packages = pkgs:
    with pkgs;
      [ungoogled-chromium]
      ++ (with llm-agents; [
        agent-browser
        bernstein
        but
        dsh
        freebuff
        gitnexus
        gnhf
        openspec
        openspecui
        qmd
      ]);
in {
  flake.nixos.packages.agents = {pkgs, ...}: {
    environment.systemPackages = packages pkgs;
  };
  flake.home.packages.agents = {pkgs, ...}: {
    home.packages = packages pkgs;
  };
  flake.nixosModules.default.imports = [config.flake.nixos.packages.agents];
  flake.homeModules.default.imports = [config.flake.home.packages.agents];
}
