# Per-user Flatpak with Flathub and GNOME Software as the app store.
{
  config,
  nix-flatpak,
  ...
}: {
  # Flake Modules
  flake.modules.homeManager.flatpak = {
    config,
    pkgs,
    ...
  }: {
    imports = [nix-flatpak.homeManagerModules.nix-flatpak];

    services.flatpak.enable = true;
    home.packages = [pkgs.flatpak pkgs.gnome-software];
    # Without system Flatpak, nothing else puts user apps in the menu.
    xdg.systemDirs.data = ["${config.xdg.dataHome}/flatpak/exports/share"];
  };

  # Home Configuration Modules
  flake.homeModules.justine.imports = [config.flake.modules.homeManager.flatpak];
}
