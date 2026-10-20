# Honcho on yggdrasil, reached by hermes on the same host. Generation runs on
# DeepSeek V4.1 Flash via the DeepSeek API; embeddings on OpenRouter (the openai
# transport's LLM_OPENAI_API_KEY), at Honcho's 1536 dimensions.
{
  config,
  lib,
  ...
}: let
  deepseek = "https://api.deepseek.com";

  honcho = {
    environmentFiles = ["/var/lib/secrets/deepseek-env" "/var/lib/secrets/openrouter-env"];

    environments = {
      DERIVER_MODEL_CONFIG__TRANSPORT = "openai";
      DERIVER_MODEL_CONFIG__MODEL = "deepseek-flash";
      DERIVER_MODEL_CONFIG__OVERRIDES__BASE_URL = deepseek;
      DERIVER_MODEL_CONFIG__OVERRIDES__API_KEY_ENV = "DEEPSEEK_API_KEY";

      SUMMARY_MODEL_CONFIG__TRANSPORT = "openai";
      SUMMARY_MODEL_CONFIG__MODEL = "deepseek-flash";
      SUMMARY_MODEL_CONFIG__OVERRIDES__BASE_URL = deepseek;
      SUMMARY_MODEL_CONFIG__OVERRIDES__API_KEY_ENV = "DEEPSEEK_API_KEY";

      DREAM_DEDUCTION_MODEL_CONFIG__TRANSPORT = "openai";
      DREAM_DEDUCTION_MODEL_CONFIG__MODEL = "deepseek-flash";
      DREAM_DEDUCTION_MODEL_CONFIG__OVERRIDES__BASE_URL = deepseek;
      DREAM_DEDUCTION_MODEL_CONFIG__OVERRIDES__API_KEY_ENV = "DEEPSEEK_API_KEY";

      DREAM_INDUCTION_MODEL_CONFIG__TRANSPORT = "openai";
      DREAM_INDUCTION_MODEL_CONFIG__MODEL = "deepseek-flash";
      DREAM_INDUCTION_MODEL_CONFIG__OVERRIDES__BASE_URL = deepseek;
      DREAM_INDUCTION_MODEL_CONFIG__OVERRIDES__API_KEY_ENV = "DEEPSEEK_API_KEY";

      DIALECTIC_LEVELS__minimal__MODEL_CONFIG__TRANSPORT = "openai";
      DIALECTIC_LEVELS__minimal__MODEL_CONFIG__MODEL = "deepseek-flash";
      DIALECTIC_LEVELS__minimal__MODEL_CONFIG__OVERRIDES__BASE_URL = deepseek;
      DIALECTIC_LEVELS__minimal__MODEL_CONFIG__OVERRIDES__API_KEY_ENV = "DEEPSEEK_API_KEY";

      DIALECTIC_LEVELS__low__MODEL_CONFIG__TRANSPORT = "openai";
      DIALECTIC_LEVELS__low__MODEL_CONFIG__MODEL = "deepseek-flash";
      DIALECTIC_LEVELS__low__MODEL_CONFIG__OVERRIDES__BASE_URL = deepseek;
      DIALECTIC_LEVELS__low__MODEL_CONFIG__OVERRIDES__API_KEY_ENV = "DEEPSEEK_API_KEY";

      DIALECTIC_LEVELS__medium__MODEL_CONFIG__TRANSPORT = "openai";
      DIALECTIC_LEVELS__medium__MODEL_CONFIG__MODEL = "deepseek-flash";
      DIALECTIC_LEVELS__medium__MODEL_CONFIG__OVERRIDES__BASE_URL = deepseek;
      DIALECTIC_LEVELS__medium__MODEL_CONFIG__OVERRIDES__API_KEY_ENV = "DEEPSEEK_API_KEY";

      DIALECTIC_LEVELS__high__MODEL_CONFIG__TRANSPORT = "openai";
      DIALECTIC_LEVELS__high__MODEL_CONFIG__MODEL = "deepseek-flash";
      DIALECTIC_LEVELS__high__MODEL_CONFIG__OVERRIDES__BASE_URL = deepseek;
      DIALECTIC_LEVELS__high__MODEL_CONFIG__OVERRIDES__API_KEY_ENV = "DEEPSEEK_API_KEY";

      DIALECTIC_LEVELS__max__MODEL_CONFIG__TRANSPORT = "openai";
      DIALECTIC_LEVELS__max__MODEL_CONFIG__MODEL = "deepseek-flash";
      DIALECTIC_LEVELS__max__MODEL_CONFIG__OVERRIDES__BASE_URL = deepseek;
      DIALECTIC_LEVELS__max__MODEL_CONFIG__OVERRIDES__API_KEY_ENV = "DEEPSEEK_API_KEY";

      EMBEDDING_MODEL_CONFIG__TRANSPORT = "openai";
      EMBEDDING_MODEL_CONFIG__MODEL = "qwen/qwen3-embedding-8b";
      EMBEDDING_MODEL_CONFIG__OVERRIDES__BASE_URL = "https://openrouter.ai/api/v1";
      # Qwen3 is 4096-dimensional; ask for the schema's 1536.
      EMBEDDING_MODEL_CONFIG__DIMENSIONS_MODE = "always";
    };
  };
in {
  my.services.honcho = {
    host = "yggdrasil";

    modules = [
      config.features.nixos.ai.honcho
      # Volumes, not the image store.
      {persist.dirs."/var/lib/containers/storage/volumes".snapshots = true;}
      {virtualisation.quadlet.containers = lib.genAttrs ["honcho-api" "honcho-deriver"] (_: {containerConfig = honcho;});}
    ];

    routes.honcho = config.flake.lib.makePrivateRoute config.my.endpoints.honcho;
  };
}
