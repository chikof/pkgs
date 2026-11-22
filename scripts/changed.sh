#!/usr/bin/env bash
# Attrs whose derivation differs from <base-rev> (new attrs included), one per line.
# A base that is empty or unknown to git yields every attr.
#   scripts/changed.sh <base-rev>
# Compares .drvPath, so a nixpkgs bump (flake.lock) or an edited dependency marks everything it reaches.
set -euo pipefail
cd "$(dirname "$0")/.."
base=${1:-}
sys=$(nix eval --raw --impure --expr builtins.currentSystem)
drvs() { # <flake dir>  ->  {attr: drvPath}
  nix eval --json "path:$1#legacyPackages.$sys" --apply '
    p: let
      one = n: v: if (v.type or "") == "derivation" then { ${n} = v.drvPath; }
        else builtins.listToAttrs (map (c: { name = "${n}.${c}"; value = v.${c}.drvPath; }) (builtins.attrNames v));
    in builtins.foldl'"'"' (a: n: a // one n p.${n}) { } (builtins.attrNames p)'
}
if [ -z "$base" ] || ! git cat-file -e "$base^{commit}" 2>/dev/null; then
  scripts/list.sh
  exit 0
fi
tmp=$(mktemp -d)
trap 'git worktree remove --force "$tmp/base" 2>/dev/null; rm -rf "$tmp"' EXIT
git worktree add -q --detach "$tmp/base" "$base"
drvs "$tmp/base" >"$tmp/old.json"
drvs "$PWD" >"$tmp/new.json"
jq -r -s '.[0] as $o | .[1] | to_entries[] | select($o[.key] != .value) | .key' "$tmp/old.json" "$tmp/new.json"
