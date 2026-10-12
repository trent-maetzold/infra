{inputs, ...}: {
  flake.overlays.llm-agents = inputs.llm-agents.overlays.shared-nixpkgs;
}
