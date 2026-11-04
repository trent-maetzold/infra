# Prime Agent accepts the same model-entry schema as pi.
{config, ...}: {
  flake.lib.makePrimeModel = config.flake.lib.makePiModel;
}
