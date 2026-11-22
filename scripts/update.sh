#!/usr/bin/env bash
# Update one package, build it, gate it on newly introduced advisories, commit only if everything passes.
# usage: scripts/update.sh <attr>   e.g. fallow | vimPlugins.cord-nvim
#
# Per-package knobs (all optional, set in the package's passthru):
#   updateArgs = [ ... ]  extra nix-update args (--version=branch, --version-regex=..., --subpackage ...)
#   npmLock = { file; jq; } checked-in package-lock.json, regenerated from the new tarball after the bump
#
# Env (all optional):
#   SOAK_DAYS      npm only resolves dependency versions published at least this many days ago (default 3)
#   UPDATE_RESULT  file that receives status=/old=/new=/stage= lines (CI passes $GITHUB_OUTPUT)
#   UPDATE_REPORT  markdown report: the cause of a failure, or the known advisories of a bump
# status: uptodate | updated | deferred (an npm dependency is newer than the cutoff; the next run retries) | failed (exit 1)
set -euo pipefail
cd "$(dirname "$0")/.."
attr=$1
[ -z "$(git status --porcelain)" ] || { echo "working tree dirty; commit or stash first" >&2; exit 1; }
ev() { nix eval --json -f default.nix "$attr" --apply "p: $1"; }
srcpath() { if [ "$(ev 'p ? src')" = true ]; then nix build -f default.nix "$attr.src" --no-link --print-out-paths; fi; }
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
log=$tmp/log
: >"$log"
report=${UPDATE_REPORT:-${TMPDIR:-/tmp}/update-$attr.md}
old=$(ev 'p.version' | jq -r .)
new=$old stage= oldsrc= newsrc=

finish() { printf 'status=%s\nold=%s\nnew=%s\nstage=%s\n' "$1" "$old" "$new" "$stage" >>"${UPDATE_RESULT:-/dev/null}"; }

# store path -> source dir; nothing for prebuilt binaries and wheels
unpack() {
  if [ -d "$1" ]; then
    echo "$1"
  elif [[ $1 == *.tgz || $1 == *.tar.gz ]]; then
    local d
    d=$(mktemp -d -p "$tmp")
    tar xzf "$1" -C "$d"
    echo "$d"/*
  fi
}

summary() {
  printf '| Package | Current | Target |\n| --- | --- | --- |\n| `%s` | %s | %s |\n' "$attr" "$old" "$new"
  local url
  url=$(ev 'p.meta.changelog or p.meta.homepage or ""' 2>/dev/null | jq -r . || true)
  [ -z "$url" ] || printf '\nChangelog: %s\n' "$url"
}

manifest_diff() {
  [ -n "$oldsrc" ] && [ -n "$newsrc" ] || return 0
  local a b f
  a=$(unpack "$oldsrc")
  b=$(unpack "$newsrc")
  [ -n "$a" ] && [ -n "$b" ] || return 0
  for f in package.json pyproject.toml Cargo.toml go.mod; do
    [ -e "$a/$f" ] || [ -e "$b/$f" ] || continue
    diff -uN --label "$old/$f" --label "$new/$f" "$a/$f" "$b/$f" || true
  done | head -n 150
}

fail() {
  {
    summary
    printf '\nFailed at stage `%s`.\n\n### Likely cause\n\n' "$stage"
    if [ "$stage" = vuln ] && [ -s "$tmp/intro.json" ]; then
      printf 'This version adds advisories that %s does not have:\n\n' "$old"
      scripts/vulns.sh table "$tmp/intro.json"
    else
      scripts/hints.sh "$log"
    fi
    local d
    d=$(manifest_diff)
    [ -z "$d" ] || printf '\n### Upstream manifest changes\n\n```diff\n%s\n```\n' "$d"
    printf '\n### Log (last 80 lines)\n\n```\n%s\n```\n' "$(tail -n 80 "$log" | sed 's/\x1b\[[0-9;]*m//g')"
  } >"$report"
  finish failed
  echo "$attr: $old -> $new failed at $stage; report: $report" >&2
  exit 1
}

stage=vuln
oldsrc=$(srcpath)
scripts/vulns.sh scan "$attr" >"$tmp/old.json" 2>>"$log" || fail

stage=update
mapfile -t args < <(ev 'p.updateArgs or []' | jq -r '.[]')
lock=$(ev 'p.npmLock or null')
if [ "$lock" = null ]; then
  nix-update -f default.nix "$attr" "${args[@]}" 2>&1 | tee -a "$log" || fail
else
  nix-update -f default.nix "$attr" "${args[@]}" --src-only 2>&1 | tee -a "$log" || fail
  if ! git diff --quiet -- packages; then
    file=$(jq -r .file <<<"$lock")
    filter=$(jq -r .jq <<<"$lock")
    pkgdir=$(unpack "$(srcpath)")
    before=$(date -u -d "-${SOAK_DAYS:-3} days" +%Y-%m-%dT%H:%M:%SZ)
    if ! (
      cd "$pkgdir"
      jq "$filter" package.json >p.json && mv p.json package.json
      npm install --package-lock-only --ignore-scripts --no-audit --no-fund --before="$before"
    ) 2>&1 | tee -a "$log"; then
      if grep -qE 'ETARGET|ENOVERSIONS|No matching version found|No versions available' "$log"; then
        new=$(ev 'p.version' | jq -r .)
        git checkout -q -- packages
        finish deferred
        echo "$attr: $new deferred, an npm dependency is newer than $before"
        exit 0
      fi
      fail
    fi
    cp "$pkgdir/package-lock.json" "packages/$file"
    nix-update -f default.nix "$attr" "${args[@]}" --version=skip --no-src 2>&1 | tee -a "$log" || fail
  fi
fi

# branch snapshots: nix-update names them <latest upstream tag>-unstable-<date>; upstream tags can be junk
# (grompt has one called "oficial"), so keep the base we already had and only take the date.
if [[ $old == *-unstable-* && $(ev 'p.version' | jq -r .) == *-unstable-* ]]; then
  base=${old%%-unstable-*}
  git diff --name-only -- 'packages/*.nix' 'packages/**/*.nix' | xargs -r sed -i -E "s/(version = \")[^\"]*(-unstable-[0-9-]+\")/\1$base\2/"
fi
new=$(ev 'p.version' | jq -r .)
if git diff --quiet -- packages; then
  echo "$attr: up to date ($old)"
  finish uptodate
  exit 0
fi
newsrc=$(srcpath)

stage=build
nix build -f default.nix "$attr" --no-link -L 2>&1 | tee -a "$log" || fail

stage=vuln
scripts/vulns.sh scan "$attr" >"$tmp/new.json" 2>>"$log" || fail
scripts/vulns.sh introduced "$tmp/old.json" "$tmp/new.json" >"$tmp/intro.json"
[ "$(jq length "$tmp/intro.json")" -eq 0 ] || fail

stage=
{
  summary
  if [ "$(jq length "$tmp/new.json")" -gt 0 ]; then
    printf '\n### Known advisories (none new in this version)\n\n'
    scripts/vulns.sh table "$tmp/new.json"
  fi
} >"$report"
git add packages
git commit -qm "$attr: $old -> $new"
finish updated
echo "$attr: $old -> $new"
