# violet: family desktop with Roblox Studio; logs in without a password.
{config, ...}: let
  inherit (config.flake) homeModules modules;
in {
  flake.users.violet = config.flake.lib.makeUser {
    name = "violet";
    hashedPassword = "";
    imports = [homeModules.family modules.homeManager.roblox-studio];
  };
}
