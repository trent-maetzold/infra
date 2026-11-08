#!/usr/bin/env bash
# Usage: nix-diff.sh <system> <old-rev> <new-rev>
# For every nixosConfiguration and homeConfiguration built for <system>, compare
# <old-rev> with <new-rev> and print a markdown section per output: unchanged
# outputs (same drv) are listed without building, changed ones get a dix diff.
# Each output is evaluated on its own, so one broken config doesn't hide the rest.
# Exits 1 if anything on the new side fails to evaluate or build.
set -uo pipefail
system=$1 old=$2 new=$3
repo=$(git rev-parse --show-toplevel)
log=$(mktemp)
fail=0

flake() { echo "git+file://$repo?rev=$1"; }

# Prints "nixos/<name>" / "home/<name>" for every output of rev $1 built for $system.
names() {
  nix eval --json "$(flake "$1")#." --apply "f: let
      pick = prefix: cs: map (n: { name = prefix + n; system = cs.\${n}.pkgs.stdenv.hostPlatform.system; })
        (builtins.attrNames cs);
    in pick \"nixos/\" (f.nixosConfigurations or {}) ++ pick \"home/\" (f.homeConfigurations or {})" |
    jq -r --arg s "$system" '.[] | select(.system == $s) | .name'
}

# drv path of output $2 at rev $1; empty if the rev doesn't have it, error log in $log.
drv() {
  local kind=${2%%/*} name=${2#*/} attr
  case $kind in
    nixos) attr="nixosConfigurations.\"$name\".config.system.build.toplevel.drvPath" ;;
    home) attr="homeConfigurations.\"$name\".activationPackage.drvPath" ;;
  esac
  nix eval --raw "$(flake "$1")#$attr" 2>"$log"
}

build() { nix build --no-link --print-out-paths "$1^out" 2>"$log" | tail -1; }

# Fenced block, trimmed so the PR comment stays under GitHub's size limit.
block() { echo '```'; grep -v '^evaluation warning' | head -c 12000; echo; echo '```'; }

for side in old new; do
  if ! list=$(names "${!side}" 2>"$log"); then
    echo "### ❌ the flake at $side ($(git rev-parse --short "${!side}")) doesn't evaluate"
    tail -n 30 "$log" | block
    [[ $side == new ]] && exit 1
    list=""
  fi
  declare "${side}_names=$list"
done

for n in $(printf '%s\n' $old_names $new_names | sort -u); do
  o="" w="" oerr="" werr=""
  grep -qx "$n" <<<"$old_names" && { o=$(drv "$old" "$n") || oerr=$(tail -n 20 "$log"); }
  grep -qx "$n" <<<"$new_names" && { w=$(drv "$new" "$n") || werr=$(tail -n 40 "$log"); }

  if [[ -n $werr ]]; then
    echo; echo "### ❌ \`$n\` doesn't evaluate"; block <<<"$werr"; fail=1
  elif ! grep -qx "$n" <<<"$new_names"; then
    echo "- \`$n\`: **removed** from the flake (the machine keeps running its current generation)"
  elif [[ -n $o && $o == "$w" ]]; then
    echo "- \`$n\`: no change"
  elif ! wp=$(build "$w") || [[ -z $wp ]]; then
    echo; echo "### ❌ \`$n\` doesn't build"; tail -n 40 "$log" | block; fail=1
  elif [[ -n $oerr ]]; then
    echo; echo "### ⚠️ \`$n\` builds, but the old side doesn't evaluate, so there's nothing to compare"; block <<<"$oerr"
  elif [[ -z $o ]]; then
    echo "- \`$n\`: **new**, builds"
  elif ! op=$(build "$o") || [[ -z $op ]]; then
    echo; echo "### ⚠️ \`$n\` builds, but the old side doesn't, so there's nothing to compare"; tail -n 20 "$log" | block
  else
    echo; echo "### \`$n\`"
    nix run --inputs-from "$repo" nixpkgs#dix -- --color=never diff "$op" "$wp" 2>&1 | block
  fi
done
exit $fail
