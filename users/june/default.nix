# june: family desktop; logs in without a password.
{config, ...}: let
  inherit (config.flake) homeModules;
in {
  flake.users.june = config.flake.lib.makeUser {
    name = "june";
    hashedPassword = "";
    imports = [homeModules.family];
  };
}
