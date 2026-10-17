# Hermes TUI and hermes-hud on the local base's state; pairs with the same side
# of `hermes`. Excludes hermes-ssh.
{hermes-agent, ...}: let
  # The NixOS base shares its HERMES_HOME with interactive users
  nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.llm-agents.hermes-hud];
    services.hermes-agent.addToSystemPackages = true;
  };

  home = {pkgs, ...}: {
    # Keyed: hermes and hermes-tui both import it
    imports = [
      {
        key = "hermes-agent#home";
        imports = [hermes-agent.homeManagerModules.default];
      }
    ];
    home.packages = [pkgs.llm-agents.hermes-hud];
    programs.hermes-agent.enable = true;
  };
in {
  # Features
  features = {
    home.ai.hermes-tui = home;
    nixos.ai.hermes-tui = nixos;
  };
}
