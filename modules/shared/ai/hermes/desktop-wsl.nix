# For the Windows Hermes Desktop on WSL: `hermes-desktop` prints the URL and
# token to enter as its remote gateway. Needs hermes or hermes-ssh.
{config, ...}: let
  backend = config.my.endpoints.hermes-backend;

  home = {pkgs, ...}: {
    home.packages = [
      (pkgs.writeShellScriptBin "hermes-desktop" ''
        echo "Remote gateway URL: ${backend.url}"
        echo "Token: $(hermes-session-token)"
      '')
    ];
  };
in {
  # Features
  features.home.ai.hermes-desktop-wsl = home;
}
