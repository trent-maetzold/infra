# Helper: the enable option for one llama-swap model.
{lib, ...}: {
  # The `services.llama-swap.models.<name>` switch for one model.
  flake.lib.makeModelOption = name:
    lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Serve the '${name}' llama-swap model.";
    };
}
