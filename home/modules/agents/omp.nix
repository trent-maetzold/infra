{
  config,
  lib,
  pkgs,
  oh-my-pi,
  ...
}: let
  cfg = config.programs.omp;

  deny = match: {
    inherit match;
    approval = "deny";
  };
  prompt = match: {
    inherit match;
    approval = "prompt";
  };

  recursiveForce = [
    "-rf"
    "-fr"
    "-Rf"
    "-RF"
    "-fR"
    "-rF"
    "-r -f"
    "-f -r"
    "-R -f"
    "-f -R"
    "-r --force"
    "--force -r"
    "--recursive --force"
    "--force --recursive"
  ];

  rmShapes = shape: [
    "rm ${shape}"
    "rm ${shape} *"
    "* rm ${shape}"
    "* rm ${shape} *"
    "*/rm ${shape}"
    "*/rm ${shape} *"
  ];

  bashPatterns = lib.concatMap (shape: map deny (rmShapes shape)) recursiveForce ++ map prompt ["ssh" "ssh *"];
in {
  imports = [oh-my-pi.homeManagerModules.default];

  config = lib.mkMerge [
    {programs.omp.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      programs.omp = {
        package = lib.mkDefault pkgs.llm-agents.omp;
        settings = {
          bash.patterns = lib.mkAfter bashPatterns;
          extensions = lib.mkAfter ["${../../config/omp/extensions/guardrails.ts}"];
          setupVersion = lib.mkDefault 2;
          symbolPreset = lib.mkDefault "nerd";
          theme.dark = lib.mkDefault "dark-forest";
        };
      };
    })
  ];
}
