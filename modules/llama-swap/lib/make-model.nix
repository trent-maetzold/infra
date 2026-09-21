# The `settings.models.<name>` definition that follows from the switch: `cfg` is
# services.llama-swap, `def` the llama-swap model attrset.
{lib}: cfg: name: def:
lib.mkIf cfg.models.${name} def
