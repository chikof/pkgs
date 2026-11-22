#!/usr/bin/env bash
# Keep one open issue per (label, attr); its title starts with "<attr>: ".
#   scripts/issue.sh upsert <label> <attr> <title> <body-file>
#   scripts/issue.sh close  <label> <attr> <comment>
set -euo pipefail
cmd=$1 label=$2 attr=$3
run=${GITHUB_RUN_ID:+$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID}
num=$(gh issue list --label "$label" --state open --limit 500 --json number,title |
  jq -r --arg p "$attr: " 'first(.[] | select(.title | startswith($p)) | .number) // empty')
case $cmd in
upsert)
  title=$4
  body="$(head -c 60000 "$5")${run:+$'\n\n'Run: $run}"
  if [ -z "$num" ]; then
    gh label create "$label" >/dev/null 2>&1 || true # already exists
    gh issue create --label "$label" --title "$title" --body "$body"
  else
    prev=$(gh issue view "$num" --json title --jq .title)
    gh issue edit "$num" --title "$title" --body "$body" >/dev/null
    # comment only on change, so a daily repeat of the same failure stays quiet
    [ "$prev" = "$title" ] || gh issue comment "$num" --body "Now: $title${run:+ ($run)}"
  fi
  ;;
close)
  [ -z "$num" ] || gh issue close "$num" --comment "$4"
  ;;
*)
  echo "usage: scripts/issue.sh upsert <label> <attr> <title> <body-file> | close <label> <attr> <comment>" >&2
  exit 2
  ;;
esac
