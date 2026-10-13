{inputs, ...}: {
  perSystem.overlays.llm-agents = inputs.llm-agents.overlays.shared-nixpkgs;
}
