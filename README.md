# supragnosis Homebrew tap

Embedded MCP server that grows an ontology from working knowledge -
https://supragnosis.dev/ (source: https://github.com/Ashon/supragnosis)

## Install

```sh
brew tap ashon/tap
brew install supragnosis                # desktop app (macOS) - pulls the server formula with it
brew install supragnosis-server         # server / CLI only (macOS / Linux, prebuilt binary)
brew services start supragnosis-server  # always-on daemon: MCP http://127.0.0.1:7373/mcp
                                        # + viewer socket ~/.supragnosis/viz.sock
```

The installed binary is named `supragnosis` either way - only the brew tokens differ.
`supragnosis` is the desktop-app cask; it depends on the `supragnosis-server` formula,
and the app attaches to the brew-managed daemon on PATH (no bundled sidecar), so a
single `brew upgrade` moves the server and the app together.

Register with an MCP client, e.g. Claude Code:

```sh
claude mcp add supragnosis --transport http http://127.0.0.1:7373/mcp
```

## Migrating from the old tokens

Before 2026-07-24 the formula was `supragnosis` and the cask was `supragnosis-app`.
Reinstall under the new names:

```sh
brew uninstall --cask supragnosis-app 2>/dev/null; brew uninstall --formula supragnosis 2>/dev/null
brew update && brew install supragnosis
```

(No `formula_renames.json` on purpose: mapping the old plain formula token would make
brew resolve `supragnosis` back to a formula and defeat the cask takeover of the name.)

## Notes

- The prebuilt binary uses keyword + hashing search. For local ONNX semantic search,
  build from source with `--features fastembed`.
- Release checksums come from the .sha256 sidecars published on each GitHub release;
  update-tap.sh in this repo rewrites the version/sha lines per release.
