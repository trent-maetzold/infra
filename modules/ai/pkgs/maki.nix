# maki from its own flake; llm-agents' copy is a release behind.
{maki, ...}: {
  flake.overlays.maki = final: _: {
    maki = maki.packages.${final.stdenv.hostPlatform.system}.default;
  };
}
