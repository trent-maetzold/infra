# justine: family desktop with Flatpak and Chrome; sets her own password at first login.
{config, ...}: {
  flake.users.justine = config.flake.lib.makeUser {
    name = "justine";
    initialPassword = "changeme";
    imports = [config.flake.homeModules.justine];
  };
}
