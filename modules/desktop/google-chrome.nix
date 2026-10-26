# Google Chrome from Flathub.
{config, ...}: {
  # Flake Modules
  flake.modules.homeManager.google-chrome.services.flatpak.packages = ["com.google.Chrome"];

  # Home Configuration Modules
  flake.homeModules.justine.imports = [config.flake.modules.homeManager.google-chrome];
}
