# Activation script deep-merging JSON file `source` over the mutable file at `target`, keeping keys only `target` has.
{
  flake.lib.makeMergedJson = pkgs: target: source: ''
    merged=$(${pkgs.jq}/bin/jq -s '.[0] * .[1]' "${target}" ${source} 2>/dev/null || cat ${source})
    run rm -f "${target}"
    run install -Dm 644 /dev/stdin "${target}" <<< "$merged"
  '';
}
