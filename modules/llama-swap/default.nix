{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.llama-swap;
  wslEnabled = config.wsl.enable or false;

  llamaServer = lib.getExe' (
    if cfg.cuda.enable
    then pkgs.llama-cpp.override {cudaSupport = true;}
    else pkgs.llama-cpp
  ) "llama-server";
in {
  imports = [./models.nix];

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfreePackages = [
      "cuda_cccl"
      "cuda_cudart"
      "cuda_nvcc"
      "cuda_nvrtc"
      "libcublas"
    ];
    services.llama-swap.settings = {
      healthCheckTimeout = lib.mkDefault 1800;
      metricsMaxInMemory = lib.mkDefault 3600;
    };
    systemd.services.llama-swap.environment.LD_LIBRARY_PATH =
      lib.mkIf (wslEnabled && cfg.cuda.enable)
      (lib.mkDefault "/usr/lib/wsl/lib");
    warnings =
      lib.optional
      ((cfg.settings.models or {}) == {})
      "llama-swap is enabled but no models are configured (services.llama-swap.settings.models). The service will serve nothing.";
  };

  options = {
    services.llama-swap.cuda.enable = lib.mkEnableOption "CUDA build of llama-cpp (for llama-server)";
    services.llama-swap.llamaServer = lib.mkOption {
      type = lib.types.path;
      default = llamaServer;
      description = "llama-server binary used by llama-swap model commands.";
    };
  };
}
