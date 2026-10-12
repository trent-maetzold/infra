{
  config,
  inputs,
  lib,
  ...
}: {
  # Package files each register flake.overlays.<name>; this composes them (alphabetical, later wins).
  flake.overlays.default = lib.composeManyExtensions (lib.attrValues (removeAttrs config.flake.overlays ["default"]));

  perSystem = {
    pkgs,
    system,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [config.flake.overlays.default];
    };
    formatter = pkgs.alejandra;
    packages = {inherit (pkgs) tredis;};
  };
}
