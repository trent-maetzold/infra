# For the Windows Hermes Desktop on WSL: `hermes-desktop` prints the URL and
# token to enter as its remote gateway. Needs hermes or hermes-ssh.
let
  home = {pkgs, ...}: {
    home.packages = [
      (pkgs.writeShellScriptBin "hermes-desktop" ''
        echo "Remote gateway URL: http://127.0.0.1:9119"
        echo "Token: $(hermes-session-token)"
      '')
    ];
  };
in {
  # Features
  features.home.ai.hermes-desktop-wsl = home;
}
