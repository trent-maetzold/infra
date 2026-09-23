# Append to the list to add one; later entries win.
{
  nixpkgs,
  oh-my-pi,
  llm-agents,
}: {
  default = nixpkgs.lib.composeManyExtensions [
    oh-my-pi.overlays.default
    llm-agents.overlays.shared-nixpkgs
    (import ./nodejs-v24.nix)
    (import ./tredis.nix)
    (import ./mini-swe-agent.nix)
  ];
}
