{config, ...}: {
  flake.home.base.asgard = {
    config,
    pkgs,
    ...
  }: {
    home = {
      homeDirectory = "/home/${config.home.username}";
      packages = with pkgs; [
        harlequin
        just
        tree
        tredis
      ];
      sessionPath = ["${config.home.homeDirectory}/.local/bin"];
    };

    programs = {
      btop = {
        enable = true;
        settings.vim_keys = true;
      };
      nh.enable = true;
    };
  };
  flake.homeModules.default.imports = [config.flake.home.base.asgard];
}
