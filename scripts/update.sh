#!/usr/bin/env bash
# Update one package, build it, commit only if the build passes.
# usage: scripts/update.sh <attr>   e.g. fallow | vimPlugins.cord-nvim
#
# Per-package knobs (all optional, set in the package's passthru):
#   updateArgs = [ ... ]  extra nix-update args (--version=branch, --version-regex=..., --subpackage ...)
#   npmLock = { file; jq; } checked-in package-lock.json, regenerated from the new tarball after the bump
set -euo pipefail
cd "$(dirname "$0")/.."
attr=$1
[ -z "$(git status --porcelain)" ] || { echo "working tree dirty; commit or stash first" >&2; exit 1; }
ev() { nix eval --json -f default.nix "$attr" --apply "p: $1"; }

old=$(ev 'p.version' | jq -r .)
mapfile -t args < <(ev 'p.updateArgs or []' | jq -r '.[]')
lock=$(ev 'p.npmLock or null')

if [ "$lock" = null ]; then
  nix-update -f default.nix "$attr" "${args[@]}"
else
  nix-update -f default.nix "$attr" "${args[@]}" --src-only
  if ! git diff --quiet -- packages; then
    file=$(jq -r .file <<<"$lock"); filter=$(jq -r .jq <<<"$lock")
    tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
    tar xzf "$(nix build -f default.nix "$attr.src" --no-link --print-out-paths)" -C "$tmp"
    (
      cd "$tmp/package"
      jq "$filter" package.json >p.json && mv p.json package.json
      npm install --package-lock-only --ignore-scripts --no-audit --no-fund
    )
    cp "$tmp/package/package-lock.json" "packages/$file"
    nix-update -f default.nix "$attr" "${args[@]}" --version=skip --no-src
  fi
fi

# branch snapshots: nix-update names them <latest upstream tag>-unstable-<date>; upstream tags can be junk
# (grompt has one called "oficial"), so keep the base we already had and only take the date.
if [[ $old == *-unstable-* && $(ev 'p.version' | jq -r .) == *-unstable-* ]]; then
  base=${old%%-unstable-*}
  git diff --name-only -- 'packages/*.nix' 'packages/**/*.nix' | xargs -r sed -i -E "s/(version = \")[^\"]*(-unstable-[0-9-]+\")/\1$base\2/"
fi
new=$(ev 'p.version' | jq -r .)
if git diff --quiet -- packages; then echo "$attr: up to date ($old)"; exit 0; fi

nix build -f default.nix "$attr" --no-link -L
git add packages
git commit -qm "$attr: $old -> $new"
echo "$attr: $old -> $new"
