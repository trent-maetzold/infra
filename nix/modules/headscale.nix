{
  config,
  lib,
  ...
}: let
  cfg = config.services.headscale;
in {
  config = lib.mkIf cfg.enable {
    services.headscale.settings.dns = {
      magic_dns = lib.mkDefault true;
      nameservers.global = lib.mkAfter ["1.1.1.1" "9.9.9.9"];
    };
  };
}
