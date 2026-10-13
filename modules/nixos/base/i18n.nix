{config, ...}: {
  flake.nixos.base.i18n = {lib, ...}: {
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
  flake.nixosModules.default.imports = [config.flake.nixos.base.i18n];
}
