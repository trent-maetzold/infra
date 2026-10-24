# Helper: one llama-swap model entry, null unless enabled.
{lib, ...}: {
  # The `settings.models.<name>` definition that follows from the switch: `cfg` is
  # services.llama-swap, `def` the llama-swap model attrset.
  flake.lib.makeModel = cfg: name: def: lib.mkIf cfg.models.${name} def;
}
