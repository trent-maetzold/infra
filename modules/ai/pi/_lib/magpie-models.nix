# magpie's models, as its /v1/models lists them: `id = [context window, output
# limit]`, and a text-only model ends with "text". Routing groups first, then
# the models behind them.
{
  "group/smart" = [272000 128000];
  "group/coding" = [272000 272000];
  "group/strong-coding" = [500000 128000];
  "group/deepseek-flash" = [1000000 393216];
  "group/deepseek-pro" = [1000000 943718 "text"];
  "group/gpt-6-astra" = [272000 128000];
  "group/gpt-6-luna" = [272000 128000];
  "group/gpt-6.1-sol" = [500000 128000];
  "group/gpt-6.1-terra" = [500000 128000];
  "group/claude-opus-5.5" = [1000000 128000];
  "group/claude-sonnet-5.5" = [1000000 128000];
  "group/claude-haiku-5.5" = [1000000 128000];
  "group/claude-fable-5-1" = [1000000 128000];
  "group/codestral-2508" = [256000 204800 "text" "no-reasoning"];

  "opencode-go/glm-5.3" = [1000000 "text"];
  "opencode-go/glm-5.3-flash" = [1000000];
  "opencode-go/glm-5.2" = [1000000 "text"];
  "opencode-go/grok-4.7" = [500000 500000];
  "opencode-go/gpt-5.6-luna" = [922000 128000];
  "opencode-go/hy3" = [192000 128000 "text"];
  "opencode-go/hy4-preview" = [1024000 64000 "text"];
  "opencode-go/kimi-k3" = [1048576];
  "opencode-go/kimi-k2.7-code" = [262144 262144];
  "opencode-go/longcat-2.0" = [1000000 "text"];
  "opencode-go/mimo-v2.6-pro" = [1048576];
  "opencode-go/mimo-v2.6-flash" = [1048576];
  "opencode-go/minimax-m3" = [1000000];
  "opencode-go/minimax-m3.1-flash" = [1000000 512000];
  "opencode-go/muse-spark-1.3-contributor" = [1048576];
  "opencode-go/muse-spark-1.2-contributor" = [1048576];
  "opencode-go/qwen3.8-max" = [1000000];
  "opencode-go/qwen3.8-flash" = [1000000];
  "opencode-go/step-5-preview" = [1000000 65536];
  "opencode-go/beam-free" = [1048576 "text"];
}
