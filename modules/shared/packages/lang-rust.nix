{
  flake.home.packages.lang-rust = {pkgs, ...}: {
    home.packages = with pkgs; [lldb rustup];
  };
}
