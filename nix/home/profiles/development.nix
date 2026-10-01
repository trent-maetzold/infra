{lib, ...}: {
  languages = lib.genAttrs [
    "bash"
    "docker"
    "git"
    "go"
    "json"
    "lua"
    "markdown"
    "nix"
    "python"
    "rust"
    "sql"
    "toml"
    "typescript"
    "yaml"
  ] (_: {enable = lib.mkDefault true;});
  programs.lazyvim.enable = lib.mkDefault true;
}
