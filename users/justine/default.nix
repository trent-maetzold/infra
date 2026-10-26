# justine: family desktop with Flatpak and Chrome; sets her own password at first login.
{config, ...}: let
  inherit (config.flake) homeModules;
in {
  flake.users.justine = config.flake.lib.makeUser {
    name = "justine";
    initialPassword = "changeme";
    imports = [homeModules.justine];
  };

  flake.homeModules.justine.imports = [homeModules.family {services.flatpak.packages = ["com.google.Chrome"];}];
}
