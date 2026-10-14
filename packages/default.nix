{
  config,
  nixpkgs,
  lib,
  ...
}: {
  # Package files add to `perSystem.overlays`; the sets compose alphabetically (later wins).
  flake.overlays.default = final: prev:
    lib.composeManyExtensions (lib.attrValues config.allSystems.${prev.stdenv.hostPlatform.system}.overlays) final prev;

  perSystem = {
    config,
    pkgs,
    system,
    ...
  }: {
    options.overlays = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = {};
    };

    config = {
      _module.args.pkgs = import nixpkgs {
        inherit system;
        overlays = lib.attrValues config.overlays;
      };
      formatter = pkgs.alejandra;
      packages = {inherit (pkgs) tredis;};
    };
  };
}
