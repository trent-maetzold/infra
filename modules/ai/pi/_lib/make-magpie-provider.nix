# pi's models.json provider for magpie: one OpenAI-compatible gateway whose
# models are its routing groups. The key comes from `$MAGPIE_GATEWAY_KEY`.
{
  baseUrl,
  models,
}: {
  name = "magpie";
  inherit baseUrl;
  api = "openai-completions";
  apiKey = "$MAGPIE_GATEWAY_KEY";

  models = map (model:
    model
    // {
      reasoning = true;
      input = ["text" "image"];
      maxTokens = 32768;
      cost = {
        input = 0;
        output = 0;
        cacheRead = 0;
        cacheWrite = 0;
      };
    })
  models;
}
