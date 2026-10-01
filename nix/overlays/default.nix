# Append to the list to add one; later entries win.
{
  colmena,
  llm-agents,
  nixpkgs,
}: {
  default = nixpkgs.lib.composeManyExtensions [
    colmena.overlays.default
    llm-agents.overlays.shared-nixpkgs
    (import ./nodejs-v24.nix)
    (import ./tredis.nix)
  ];
}
