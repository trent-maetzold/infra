{config, ...}: {
  flake.modules.nixos.asgard = {
    lib,
    pkgs,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      alejandra
      btop
      curl
      gcc
      git
      gnumake
      just
      openssh
      openssl
      pkg-config
      tree
      unzip
      wget
    ];
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
    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      extra-substituters = ["https://cache.numtide.com"];
      extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
      trusted-users = ["@wheel"];
    };
    programs.nh.enable = true;
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [stdenv.cc.cc.lib];
    };
    security.sudo.wheelNeedsPassword = false;
    services.openssh.settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  flake.nixosModules.default.imports = [config.flake.modules.nixos.asgard];
}
