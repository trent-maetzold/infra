# autolith from its own flake; llm-agents' copy is 0.41.2 against upstream 0.67.5.
{autolith, ...}: {
  flake.overlays.autolith = final: _: {
    autolith = autolith.packages.${final.stdenv.hostPlatform.system}.default;
  };
}
