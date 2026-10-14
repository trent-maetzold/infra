{config, ...}: let
  out = {lib, ...}: {
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
  # Features
  features.nixos.base.i18n = out;

  # NixOS Modules
  flake.nixosModules.default.imports = [config.features.nixos.base.i18n];
}
