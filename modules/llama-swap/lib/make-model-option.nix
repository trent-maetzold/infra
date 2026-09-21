# The `services.llama-swap.models.<name>` switch for one model. The model files
# (models/default.nix, models/gpu.nix) are otherwise just data.
{lib}: name:
lib.mkOption {
  type = lib.types.bool;
  default = false;
  description = "Serve the '${name}' llama-swap model.";
}
