# pkgs

Custom Nix packages.

## Packages

| Name                                   | Description                                                     |
| -------------------------------------- | --------------------------------------------------------------- |
| `equibop`                              | Other cutest Discord client mod                                 |
| `vimPlugin.cord-nvim`                  | Discord Rich Presence for Neovim                                |
| `unfetch`                              | Simple and customizable system fetch                            |
| `nano-ffmpeg`                          | Ffmpeg made easy (TUI)                                          |
| `g`                                    | minimal yet styled git wrapper.                                 |
| `cavemem`                              | Cross-agent persistent memory for AI coding assistants          |
| `typescript-svelte-plugin`             | TypeScript plugin for Svelte                                    |
| `fallow`                               | Rust-native codebase intelligence for TypeScript and JavaScript |
| `bacon-ls`                             | LSP server exposing cargo/bacon diagnostics for Rust            |
| `grompt`                               | starship.rs killer                                              |
| `graphify`                             | AI coding assistant skill.                                      |
| `taste-skill`                          | Anti-slop frontend design skill for coding agents               |
| `security-audit-skill`                 | Multi-phase security audit skill with verified findings         |
| `google-sans-flex`                     | Google Sans Flex variable font (OFL)                            |
| `tersio`                               | Token saver and usage tracker for coding agents                 |
| `headroom`                             | Context compression proxy for coding agents                     |
| `mcp-for-blender`                      | MCP server for driving Blender, with its addon bundled          |
| `blender-mcp`                          | Blender GUI that auto-loads the mcp-for-blender addon           |
| `symposium`                            | AI the Rust Way: per-crate skills, hooks and MCP for agents     |
| `symposium-rust-analyzer`              | MCP server exposing rust-analyzer LSP features                  |
| `sonora`                               | Native, familiar music streaming client                         |

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
