# justine: family desktop with Chrome; sets her own password at first login.
{config, ...}: let
  inherit (config.flake) homeModules modules;
in {
  flake.users.justine = config.flake.lib.makeUser {
    name = "justine";
    initialPassword = "changeme";
    imports = [homeModules.family modules.homeManager.google-chrome];
  };
}
