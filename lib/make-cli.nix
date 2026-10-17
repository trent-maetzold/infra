# Package installing a PEP 723 (`uv init --script`) script as `name`;
# pyproject-nix swaps its shebang for a Nix Python with its dependencies. `env`
# is baked into a wrapper.
{pyproject-nix, ...}: {
  flake.lib.makeCli = {
    pkgs,
    name,
    script,
    env ? {},
  }: let
    cli = pkgs.writeScriptBin name ((pyproject-nix.lib.scripts.loadScript {inherit name script;}).renderWithPackages {python = pkgs.python3;});
    set = pkgs.lib.concatMapAttrsStringSep " " (n: v: "--set ${n} ${pkgs.lib.escapeShellArg v}") env;
  in
    pkgs.runCommand name {nativeBuildInputs = [pkgs.makeWrapper];} "makeWrapper ${cli}/bin/${name} $out/bin/${name} ${set}";
}
