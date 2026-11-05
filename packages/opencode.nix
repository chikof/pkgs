{opencode}:
# nixpkgs 1d06008 ships a stale node_modules hash for 2.2.5 (fixed on master in c399e1b7, not in
# nixos-unstable yet). Drop this file once the channel has the fix.
opencode.overrideAttrs (old: {
  node_modules = old.node_modules.overrideAttrs {
    outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
  };
})
