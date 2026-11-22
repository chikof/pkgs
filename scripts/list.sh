#!/usr/bin/env bash
# Print package attrs, one per line (nested sets flattened), for the current system.
#   scripts/list.sh            everything (build/test matrix)
#   scripts/list.sh updatable  minus the REA family (versions pinned to what REA verifies), blender-mcp (a launcher that follows mcp-for-blender),
#                              and google-sans-flex (a font pinned to a google/fonts monorepo commit; nix-update cannot follow it)
set -euo pipefail
cd "$(dirname "$0")/.."
sys=$(nix eval --raw --impure --expr builtins.currentSystem)
out=$(nix eval --json ".#legacyPackages.$sys" --apply '
  p: builtins.concatLists (builtins.attrValues (builtins.mapAttrs
    (n: v: if (v.type or "") == "derivation" then [ n ] else map (c: "${n}.${c}") (builtins.attrNames v)) p))
' | jq -r '.[]')
if [ "${1:-}" = updatable ]; then grep -vxE 'rea|rea-.*|kuna|wakaru|jadx-headless-mcp|blender-mcp|google-sans-flex' <<<"$out"; else echo "$out"; fi
