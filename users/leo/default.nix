# leo: family desktop with Roblox Studio; logs in without a password.
{config, ...}: let
  inherit (config.flake) homeModules modules;
in {
  flake.users.leo = config.flake.lib.makeUser {
    name = "leo";
    hashedPassword = "";
    imports = [homeModules.family modules.homeManager.roblox-studio];
  };
}
