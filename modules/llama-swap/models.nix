{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.services.llama-swap;

  modelOption = name:
    mkOption {
      type = types.bool;
      default = false;
      description = "Serve the '${name}' llama-swap model.";
    };
  modelDefinition = name: def: mkIf cfg.models.${name} def;
in {
  config = mkIf cfg.enable {
    services.llama-swap.settings.models = lib.filterAttrs (_: v: v != null) {
      "qwopus3.6-35b-a3b-coder" = modelDefinition "qwopus3.6-35b-a3b-coder" {
        cmd = lib.mkDefault ''
          ${cfg.llamaServer} --port ''${PORT} --host 127.0.0.1 \
            -hf Jackrong/Qwopus3.6-35B-A3B-Coder-MTP-GGUF:Q4_K_M \
            --no-mmproj --reasoning-budget 0 --ctx-size 262144 --flash-attn on \
            --cache-type-k q8_0 --cache-type-v q8_0 --jinja --parallel 1 \
            --n-gpu-layers 999 --cpu-moe --threads 8 --timeout 900
        '';
        capabilities = {
          "in" = ["text"];
          out = ["text"];
          tools = lib.mkDefault true;
          context = lib.mkDefault 262144;
        };
      };
      "refact-1.6b-fim" = modelDefinition "refact-1.6b-fim" {
        cmd = lib.mkDefault ''
          ${cfg.llamaServer} --port ''${PORT} --host 127.0.0.1 \
            -hf mradermacher/Refact-1_6B-fim-i1-GGUF:i1-Q6_K \
            --ctx-size 4096 --flash-attn on --parallel 1 \
            --n-gpu-layers 99 --threads 8 --timeout 900 \
            --cache-reuse 64
        '';
        capabilities = {
          "in" = ["text"];
          out = ["text"];
          tools = lib.mkDefault false;
          context = lib.mkDefault 4096;
        };
      };
      "lfm2.5-2.6b" = modelDefinition "lfm2.5-2.6b" {
        cmd = lib.mkDefault ''
          ${cfg.llamaServer} --port ''${PORT} --host 127.0.0.1 \
            -hf LiquidAI/LFM2.5-2.6B-GGUF:Q4_K_M \
            --ctx-size 131072 --temp 0.1 --top-k 50 --repeat-penalty 1.1 \
            --jinja --parallel 1 --n-gpu-layers 0 --threads 8 --timeout 900
        '';
        capabilities = {
          "in" = ["text"];
          out = ["text"];
          tools = lib.mkDefault true;
          context = lib.mkDefault 131072;
        };
      };
      "lfm2.5-8b-a1b" = modelDefinition "lfm2.5-8b-a1b" {
        cmd = lib.mkDefault ''
          ${cfg.llamaServer} --port ''${PORT} --host 127.0.0.1 \
            -hf LiquidAI/LFM2.5-8B-A1B-GGUF:Q4_K_M \
            --ctx-size 128000 --temp 0.1 --top-k 50 --repeat-penalty 1.1 \
            --jinja --parallel 1 --n-gpu-layers 0 --threads 8 --timeout 900
        '';
        capabilities = {
          "in" = ["text"];
          out = ["text"];
          tools = lib.mkDefault true;
          context = lib.mkDefault 128000;
        };
      };
    };
  };

  options.services.llama-swap.models = {
    "qwopus3.6-35b-a3b-coder" = modelOption "qwopus3.6-35b-a3b-coder";
    "refact-1.6b-fim" = modelOption "refact-1.6b-fim";
    "lfm2.5-2.6b" = modelOption "lfm2.5-2.6b";
    "lfm2.5-8b-a1b" = modelOption "lfm2.5-8b-a1b";
  };
}
