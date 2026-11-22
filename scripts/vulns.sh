#!/usr/bin/env bash
# Known advisories (osv.dev) in one package's lockfiles.
#   scripts/vulns.sh scan <attr>             JSON array of {key, ids, package, version, ecosystem, cvss, source}
#   scripts/vulns.sh introduced <old> <new>  entries of <new> whose advisory key is absent from <old>
#   scripts/vulns.sh table <file>            markdown table
# Scans the checked-in npm lockfile (passthru.npmLock) and lockfiles at the top of an unpacked src.
# Python dependencies come from nixpkgs and are not covered here.
set -euo pipefail
cd "$(dirname "$0")/.."
case $1 in
scan)
  attr=$2
  ev() { nix eval --json -f default.nix "$attr" --apply "p: $1"; }
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  args=()
  lock=$(ev 'p.npmLock.file or null' | jq -r '. // empty')
  if [ -n "$lock" ]; then
    mkdir "$tmp/npm"
    cp "packages/$lock" "$tmp/npm/package-lock.json"
    args+=(-L "$tmp/npm/package-lock.json")
  fi
  if [ "$(ev 'p ? src')" = true ]; then
    src=$(nix build -f default.nix "$attr.src" --no-link --print-out-paths)
    # tarballs and prebuilt binaries carry no lockfile to scan
    if [ -d "$src" ]; then args+=("$src"); fi
  fi
  if [ ${#args[@]} -eq 0 ]; then echo '[]'; exit 0; fi
  rc=0
  osv-scanner scan source --format json "${args[@]}" >"$tmp/osv.json" || rc=$?
  case $rc in
  0 | 1) ;;
  128) echo '[]'; exit 0 ;;
  *) exit "$rc" ;;
  esac
  jq --arg tmp "$tmp/" --arg lock "packages/$lock" '
    [.results[]? | .source.path as $path
     | (if ($path | startswith($tmp)) then $lock else ($path | sub("^/nix/store/[^/]+/"; "src/")) end) as $src
     | .packages[]? | .package as $p
     | select(($p.ecosystem == "Go" and ($p.name == "stdlib" or $p.name == "toolchain")) | not)
     | .groups[]?
     | {key: (.ids | sort | join(",")), ids, package: $p.name, version: $p.version,
        ecosystem: $p.ecosystem, cvss: (.max_severity // ""), source: $src}]
    | unique_by([.key, .package, .version, .source])' "$tmp/osv.json"
  ;;
introduced)
  jq -s '(.[0] | map(.key)) as $old | .[1] | map(select(.key as $k | ($old | any(. == $k)) | not))' "$2" "$3"
  ;;
table)
  jq -r '"| Advisory | Package | Version | CVSS | Lockfile |", "| --- | --- | --- | --- | --- |",
    (.[] | "| \(.ids | map("[\(.)](https://osv.dev/vulnerability/\(.))") | join(" ")) | `\(.package)` | \(.version) | \(.cvss) | `\(.source)` |")' "$2"
  ;;
*)
  echo "usage: scripts/vulns.sh scan <attr> | introduced <old.json> <new.json> | table <file.json>" >&2
  exit 2
  ;;
esac
