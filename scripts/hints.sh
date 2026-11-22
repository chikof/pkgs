#!/usr/bin/env bash
# Likely causes of a failed update or build, as markdown bullets.  usage: scripts/hints.sh <log>
set -euo pipefail
hints=(
  'Could not find a url in the derivations src|Please specify the version'
  'nix-update cannot find new versions for this src. Set `passthru.updateArgs` (`--url=<upstream repo>`, `--version-regex=...`) or add the attr to the exclusion regex in `scripts/list.sh`.'
  'returned error: 404|HTTP error 404'
  'A download returned 404: the release asset is missing or was renamed upstream. Assets of a release published minutes ago may not exist yet; the next run retries.'
  'hash mismatch in fixed-output derivation'
  'A fixed-output hash changed. If the URL did not change, upstream re-tagged or re-uploaded the release: verify before accepting it.'
  'not satisfied by version'
  'A Python runtime dependency needs a newer version than nixpkgs ships. Add it to `pythonRelaxDeps` if it still works, or wait for nixpkgs.'
  'ModuleNotFoundError|No module named'
  'Upstream added a Python dependency: add it to `dependencies`.'
  "doesn't match anything in"
  'A `substituteInPlace --replace-fail` pattern no longer matches: upstream changed that file; update the pattern.'
  'Hunk #[0-9]+ FAILED|can.t find file to patch|Reversed \(or previously applied\) patch'
  'A local patch no longer applies. Drop it if upstream merged the fix, otherwise rebase it.'
  'requires rustc [0-9]'
  'Upstream raised its minimum Rust version above the rustc in nixpkgs.'
  'go.mod requires go >='
  'Upstream requires a newer Go than nixpkgs defaults to: switch to a newer `buildGo1xxModule` or wait for nixpkgs.'
  'EBADENGINE|Unsupported engine'
  'Upstream requires a newer Node.js: set `nodejs = nodejs_XX`.'
  'npm error|npm ERR!'
  'npm failed while regenerating the lockfile; compare the package.json changes below.'
  'ERR_PNPM_'
  'pnpm failed; the `pnpmDeps` hash or `fetcherVersion` may need updating.'
  'Did not find version'
  'Smoke test failed: the binary did not print its version (startup crash, missing runtime dependency, or changed `--version` output).'
  'could not satisfy dependency'
  'The prebuilt binary links a new shared library: add the package that provides it to `buildInputs`.'
  'is marked as (insecure|broken)'
  'A nixpkgs dependency is marked insecure or broken.'
  'No space left on device'
  'The CI runner ran out of disk: add the "Free disk" step to this job.'
)
found=
for ((i = 0; i < ${#hints[@]}; i += 2)); do
  if grep -qE -- "${hints[i]}" "$1"; then
    echo "- ${hints[i + 1]}"
    found=1
  fi
done
[ -n "$found" ] || echo "- No known pattern matched; read the log below."
