{
  config,
  lib,
  ...
}: let
  cfg = config.services.headplane;
in {
  config = lib.mkIf cfg.enable {
    services.headplane.settings.headscale.config_path = lib.mkDefault config.services.headscale.configFile;
  };
}
