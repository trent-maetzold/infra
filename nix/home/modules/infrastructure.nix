{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.infrastructure;
in {
  config = lib.mkIf cfg.enable {
    home.packages = lib.mkAfter (with pkgs; [age colmena nixos-anywhere oci-cli opentofu ragenix]);
  };

  options.programs.infrastructure.enable = lib.mkEnableOption "infrastructure tools";
}
