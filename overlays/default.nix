# asgard's overlays, composed into the single function `nixpkgs.overlays` wants.
# flake.nix re-exports this as the `overlays` output and applies `default` to its
# own pkgs. Append to the list to add one; later entries win.
{
  nixpkgs,
  llm-agents,
}: {
  default = nixpkgs.lib.composeManyExtensions [
    llm-agents.overlays.shared-nixpkgs
    (import ./nodejs-v24.nix)
  ];
}
