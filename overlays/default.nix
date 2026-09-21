# Append to the list to add one; later entries win.
{
  nixpkgs,
  llm-agents,
}: {
  default = nixpkgs.lib.composeManyExtensions [
    llm-agents.overlays.shared-nixpkgs
    (import ./nodejs-v24.nix)
    (import ./tredis.nix)
  ];
}
