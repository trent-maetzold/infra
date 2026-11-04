# pi's models.json provider for magpie: one OpenAI-compatible gateway whose
# models are its routing groups and the models behind them, from the table in
# ./magpie-models.nix. The key comes from `$MAGPIE_GATEWAY_KEY`.
{
  baseUrl,
  models,
}: let
  inherit (builtins) attrNames concatMap elem filter length;

  # `[context window, output limit, flags…]` → one pi model.
  toModel = id: spec: let
    flags = filter (value: builtins.isString value) spec;
    limits = filter builtins.isInt spec;
  in {
    contextWindow = builtins.head limits;
    maxTokens =
      if length limits > 1
      then builtins.elemAt limits 1
      else 131072;
    input =
      if elem "text" flags
      then ["text"]
      else ["text" "image"];
    reasoning = !(elem "no-reasoning" flags);
    cost = {
      input = 0;
      output = 0;
      cacheRead = 0;
      cacheWrite = 0;
    };
    inherit id;
  };
in {
  name = "magpie";
  inherit baseUrl;
  api = "openai-completions";
  apiKey = "$MAGPIE_GATEWAY_KEY";

  models = concatMap (id: [(toModel id models.${id})]) (attrNames models);
}
