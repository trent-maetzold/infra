{
  config,
  lib,
  pkgs,
  oh-my-pi,
  ...
}: let
  cfg = config.programs.omp;

  guardrails = import ./guardrails.nix;

  deny = map (match: {
    inherit match;
    approval = "deny";
  });
  prompt = map (match: {
    inherit match;
    approval = "prompt";
  });
in {
  imports = [oh-my-pi.homeManagerModules.default];

  config = lib.mkMerge [
    {programs.omp.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      programs.omp = {
        package = lib.mkDefault pkgs.llm-agents.omp;
        settings = {
          tools.approval = {
            bash = lib.mkDefault "allow";
            computer = lib.mkDefault "prompt";
            eval = lib.mkDefault "prompt";
          };
          bash.patterns = lib.mkAfter (
            deny guardrails.bash.deny.credentials
            ++ deny guardrails.bash.deny.decryptors
            ++ deny guardrails.bash.deny.environment
            ++ prompt guardrails.bash.prompt.environment
            ++ prompt guardrails.bash.prompt.removals
            ++ prompt guardrails.bash.prompt.remotes
          );
          bashInterceptor.enabled = lib.mkDefault true;
          symbolPreset = lib.mkDefault "nerd";
          theme.dark = lib.mkDefault "dark-forest";
        };
      };
    })
  ];
}
