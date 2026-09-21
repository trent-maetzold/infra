{
  config,
  lib,
  ...
}: let
  cfg = config.virtualisation.podman;
in {
  config = lib.mkIf cfg.enable {
    virtualisation.containers.containersConf.settings.network.pasta_options = lib.mkAfter ["--ipv4-only"];
  };
}
