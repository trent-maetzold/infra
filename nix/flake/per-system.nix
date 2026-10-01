{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    evaluated = import ../checks {
      self = inputs.self;
      inherit pkgs system;
    };
    migration = import ../checks/migration.nix {
      self = inputs.self;
      inherit pkgs system;
    };
    nixosDoc = inputs.self.lib.optionsDoc pkgs evaluated.nixos;
    homeDoc = inputs.self.lib.optionsDoc pkgs evaluated.homeManager;
  in {
    formatter = pkgs.writeShellScriptBin "format" ''exec ${pkgs.alejandra}/bin/alejandra "''${@:-.}"'';
    apps.colmena = {
      type = "app";
      program = pkgs.lib.getExe inputs.colmena.packages.${system}.colmena;
      meta.description = "Colmena deployment CLI";
    };
    packages = {
      inherit (inputs.colmena.packages.${system}) colmena;
      inherit (pkgs) ragenix;
      options-json = pkgs.runCommand "asgard-options-json" {} ''
        mkdir -p $out/nixos $out/home-manager
        ln -s ${nixosDoc.optionsJSON}/share/doc/nixos/options.json $out/nixos/options.json
        ln -s ${homeDoc.optionsJSON}/share/doc/nixos/options.json $out/home-manager/options.json
      '';
      options-commonmark = pkgs.runCommand "asgard-options.md" {} ''
        cat ${nixosDoc.optionsCommonMark} ${homeDoc.optionsCommonMark} > $out
      '';
    };
    checks = {
      module-evaluation = assert evaluated.passed;
        pkgs.writeText "asgard-module-evaluation.json" (builtins.toJSON evaluated.report);
      credential-environment = pkgs.runCommand "asgard-credential-environment" {} ''
        export XDG_RUNTIME_DIR="$TMPDIR/runtime"
        mkdir -p "$XDG_RUNTIME_DIR/agenix"
        printf '%s' synthetic-token > "$XDG_RUNTIME_DIR/agenix/pi-OPENCODE_API_KEY"
        source ${pkgs.writeText "credential-environment.sh" migration.environment}
        test "$OPENCODE_API_KEY" = synthetic-token
        test -z "''${OPENROUTER_API_KEY+x}"
        touch $out
      '';
    };
  };
}
