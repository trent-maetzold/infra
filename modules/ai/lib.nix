# Consumer functions for the ai domain: jail a harness, merge a JSON config.
{
  flake.lib.makeJail = import ./_lib/make-jail.nix;
  flake.lib.makeMergedJson = import ./_lib/make-merged-json.nix;
}
