#!/usr/bin/env bash
# Land auto-update PRs whose bump commit is at least SOAK_DAYS old: rebase onto main, rebuild,
# re-check advisories (some are published during the soak), push to main.
# A PR that no longer builds or gained advisories is closed with an issue; the next update run starts over from main.
# ATTR_INPUT (set by a dispatch for one package) restricts this to that package's PR.
set -euo pipefail
cd "$(dirname "$0")/.."
soak=${SOAK_DAYS:-3}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
reject() { # <pr> <attr> <issue title>; body in $tmp/body.md
  scripts/issue.sh upsert update-blocked "$2" "$3" "$tmp/body.md"
  gh pr close "$1" --delete-branch --comment "Not landed: $3."
}
mapfile -t prs < <(gh pr list --label auto-update --state open --limit 200 --json number,headRefName,title \
  --jq '.[] | [.number, .headRefName, .title] | @tsv')
for line in "${prs[@]}"; do
  IFS=$'\t' read -r n ref title <<<"$line"
  attr=${ref#update/}
  [ -z "${ATTR_INPUT:-}" ] || [ "$attr" = "$ATTR_INPUT" ] || continue # a dispatch for one attr must not land the others
  bump=${title#*: }
  git fetch -q origin "+refs/heads/main:refs/remotes/origin/main" "+refs/heads/$ref:refs/remotes/origin/$ref"
  age=$((($(date +%s) - $(git log -1 --format=%at "origin/$ref")) / 86400))
  if [ "$age" -lt "$soak" ]; then
    echo "$attr: soaking ($age/$soak days)"
    continue
  fi
  git checkout -q --detach origin/main
  if ! scripts/vulns.sh scan "$attr" >"$tmp/old.json"; then
    echo "::warning::$attr: advisory scan failed; retrying next run"
    continue
  fi
  git checkout -q -B land "origin/$ref"
  if ! git rebase -q origin/main; then
    git rebase --abort
    gh pr close "$n" --delete-branch --comment "Conflicts with main; the next update run starts over from main."
    continue
  fi
  if git diff --quiet origin/main HEAD; then
    gh pr close "$n" --delete-branch --comment "main already has this change."
    continue
  fi
  if ! nix build -f default.nix "$attr" --no-link -L 2>&1 | tee "$tmp/log"; then
    {
      printf '`%s` passed its gates when opened but no longer builds on current main.\n\n### Likely cause\n\n' "$title"
      scripts/hints.sh "$tmp/log"
      printf '\n### Log (last 80 lines)\n\n```\n%s\n```\n' "$(tail -n 80 "$tmp/log" | sed 's/\x1b\[[0-9;]*m//g')"
    } >"$tmp/body.md"
    reject "$n" "$attr" "$attr: $bump no longer builds on main"
    continue
  fi
  if ! scripts/vulns.sh scan "$attr" >"$tmp/new.json"; then
    echo "::warning::$attr: advisory scan failed; retrying next run"
    continue
  fi
  scripts/vulns.sh introduced "$tmp/old.json" "$tmp/new.json" >"$tmp/intro.json"
  if [ "$(jq length "$tmp/intro.json")" -gt 0 ]; then
    { printf 'Advisories published during the soak affect `%s` but not the version on main:\n\n' "$title"; scripts/vulns.sh table "$tmp/intro.json"; } >"$tmp/body.md"
    reject "$n" "$attr" "$attr: $bump blocked at vuln"
    continue
  fi
  git push -q -f origin "HEAD:refs/heads/$ref"
  if ! git push -q origin HEAD:main; then
    echo "::warning::$attr: main moved; retrying next run"
    continue
  fi
  # GitHub marks the PR merged once its head commit is on main; close it ourselves if that has not happened yet
  [ "$(gh pr view "$n" --json state --jq .state)" = MERGED ] || gh pr close "$n" --comment "Landed in $(git rev-parse HEAD)."
  git push -q origin --delete "$ref" 2>/dev/null || true # already deleted by GitHub
  echo "$attr: landed $bump"
done
