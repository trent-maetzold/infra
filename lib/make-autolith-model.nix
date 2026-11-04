# A shared model description as an Autolith provider model property list.
{lib, ...}: {
  flake.lib.makeAutolithModel = {
    id,
    contextWindow,
    reasoning ? true,
    ...
  }: ''(:name "${lib.escape ["\\" "\""] id}" :context-window ${toString contextWindow}${lib.optionalString (!reasoning) " :reasoning-efforts (\"none\")"})'';
}
