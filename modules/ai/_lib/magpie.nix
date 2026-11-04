# Magpie's shared connection and model descriptions for the harness adapters.
let
  table = import ./magpie-models.nix;
  makeModel = id: let
    spec = table.${id};
    flags = builtins.filter builtins.isString spec;
    limits = builtins.filter builtins.isInt spec;
  in {
    inherit id;
    contextWindow = builtins.head limits;
    maxTokens =
      if builtins.length limits > 1
      then builtins.elemAt limits 1
      else 131072;
    input =
      if builtins.elem "text" flags
      then ["text"]
      else ["text" "image"];
    reasoning = !(builtins.elem "no-reasoning" flags);
  };
  models = map makeModel (builtins.attrNames table);
  makeModels = makeHarnessModel: map makeHarnessModel models;
in {
  inherit makeModels;
  makeModelText = makeHarnessModel: builtins.concatStringsSep "\n" (makeModels makeHarnessModel);
  name = "magpie";
  baseUrl = "https://magpie.ts.trkm.io/v1";
  apiKeyEnv = "MAGPIE_GATEWAY_KEY";
}
