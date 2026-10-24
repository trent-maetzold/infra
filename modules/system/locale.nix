# en_US.UTF-8 locale and the flake's time zone.
{config, ...}: let
  modules.nixos = {
    config,
    lib,
    ...
  }: {
    time.timeZone = config.vars.timeZone;

    i18n = {
      defaultLocale = "en_US.UTF-8";

      extraLocaleSettings = lib.genAttrs [
        "LC_ADDRESS"
        "LC_IDENTIFICATION"
        "LC_MEASUREMENT"
        "LC_MONETARY"
        "LC_NAME"
        "LC_NUMERIC"
        "LC_PAPER"
        "LC_TELEPHONE"
        "LC_TIME"
      ] (_: "en_US.UTF-8");
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.locale = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.default.imports = [config.flake.modules.nixos.locale];
}
