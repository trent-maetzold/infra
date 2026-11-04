# A shared model description as a pi models.json entry.
{
  flake.lib.makePiModel = {
    id,
    contextWindow,
    maxTokens ? 131072,
    input ? ["text" "image"],
    reasoning ? true,
    ...
  }: {
    inherit id contextWindow maxTokens input reasoning;
    cost = {
      input = 0;
      output = 0;
      cacheRead = 0;
      cacheWrite = 0;
    };
  };
}
