# magpie's /v1/models as pi's model table: `id = [context window, output limit,
# flags…]`, the output limit left out when it is pi's default of 131072 and a
# text-only model ending with "text", one without reasoning with "no-reasoning".
# Bare ids alias the prefixed ones, so only prefixed ids and routing groups stay:
# one block per prefix, models sorted, so a refresh diffs cleanly.
def line:
  . as $m
  | (
    [$m.context_window]
    + (if $m.max_output_tokens != 131072 then [$m.max_output_tokens] else [] end)
    + (if $m.modalities.input | index("image") then [] else ["\"text\""] end)
    + (if $m.reasoning then [] else ["\"no-reasoning\""] end)
  )
  | "  \"\($m.id)\" = [\(map(tostring) | join(" "))];";

"# magpie's models, as its /v1/models lists them: `id = [context window, output",
"# limit]`, and a text-only model ends with \"text\", one without reasoning with",
"# \"no-reasoning\". Routing groups first, then the models behind them.",
"{",
(
  [.data[] | select(.id | contains("/"))]
  | group_by(.id | split("/")[0])
  | map(sort_by(.id) | map(line))
  | reduce .[] as $group ([]; if length == 0 then $group else . + [""] + $group end)
  | .[]
),
"}"
