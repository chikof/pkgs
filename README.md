# pkgs

Custom Nix packages.

## Packages

| Name      | Description                     |
| --------- | ------------------------------- |
| `equibop` | Other cutest Discord client mod |

## Install

### Run without installing

```bash
nix run github:chikof/pkgs#<package>
```

### NixOS / home-manager (overlay)

Add to your flake inputs:

```nix
inputs.custom-pkgs.url = "github:chikof/pkgs";
```

Apply the overlay:

```nix
nixpkgs.overlays = [ inputs.custom-pkgs.overlays.default ];
```

Then use `pkgs.<package>` anywhere in your config.

### Build locally

```bash
nix build .#<package>
```

## Development

```bash
nix develop   # enter shell with nix-update, alejandra, etc.
nix fmt       # format all nix files
nix flake check
```
