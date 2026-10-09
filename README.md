# Ashon's Homebrew tap

| Token | Kind | What |
| --- | --- | --- |
| `supragnosis` | cask | supragnosis desktop app (pulls `supragnosis-server`) |
| `supragnosis-server` | formula | supragnosis server / CLI |
| `orbly` | cask | Orbly desktop app (Slack bot on local claude/codex CLIs), formerly `verda` |

```sh
brew tap ashon/tap
```

## supragnosis

Embedded MCP server that grows an ontology from working knowledge -
https://supragnosis.dev/ (source: https://github.com/Ashon/supragnosis)

### Install

```sh
brew tap ashon/tap
brew install supragnosis                # desktop app (macOS) - pulls the server formula with it
brew install supragnosis-server         # server / CLI only (macOS / Linux, prebuilt binary)
brew services start supragnosis-server  # always-on daemon: MCP http://127.0.0.1:7373/mcp
                                        # + viewer socket ~/.supragnosis/viz.sock
```

The installed binary is named `supragnosis` either way - only the brew tokens differ.
`supragnosis` is the desktop-app cask; it depends on the `supragnosis-server` formula,
and the app attaches to the brew-managed daemon on PATH (no bundled sidecar).

Upgrading takes two commands - `brew upgrade` swaps the binaries and relaunches the
app, but it does not restart a running daemon (the formula caveats print the same
reminder). Without the restart the old daemon keeps running from the deleted keg:

```sh
brew upgrade
brew services restart supragnosis-server
```

Register with an MCP client, e.g. Claude Code:

```sh
claude mcp add supragnosis --transport http http://127.0.0.1:7373/mcp
```

### Migrating from the old tokens

Before 2026-07-24 the formula was `supragnosis` and the cask was `supragnosis-app`.
Reinstall under the new names. Stopping the service comes before uninstall - brew
uninstall does not stop a running service or remove its launchd plist:

```sh
brew services stop supragnosis 2>/dev/null
brew uninstall --cask supragnosis-app 2>/dev/null; brew uninstall --formula supragnosis 2>/dev/null
brew update && brew install supragnosis
```

(No `formula_renames.json` on purpose: mapping the old plain formula token would make
brew resolve `supragnosis` back to a formula and defeat the cask takeover of the name.)

### Notes

- The prebuilt binary uses keyword + hashing search. For local ONNX semantic search,
  build from source with `--features fastembed`.
- Release checksums come from the .sha256 sidecars published on each GitHub release;
  update-tap.sh in this repo rewrites the version/sha lines per release.

## orbly

Your orbiting assistant: a Slack bot that answers mentions with your local claude or codex CLI, run in a
Docker sandbox - https://github.com/Ashon/orbly. The cask installs the signed and notarized
Orbly.app (Apple silicon or Intel, macOS 12+); the app carries the bot, so there is no formula.

```sh
brew install --cask orbly
brew upgrade --cask orbly     # quits the running app first (the bot finishes its requests), then reopens it
```

Config and run history live in `~/.orbly` and are kept on upgrade and uninstall. Orbly's release
workflow renders `Casks/orbly.rb` from https://github.com/Ashon/orbly/tree/main/deploy/homebrew.

### Migrating from verda

The cask was `verda` until v0.1.2. `cask_renames.json` maps it to `orbly`, so `brew update && brew upgrade`
moves an existing install over and replaces Verda.app with Orbly.app. Orbly keeps using `~/.verda` until it
is moved (see "Migrating from Verda" in the Orbly README). If brew keeps listing `verda`:

```sh
brew uninstall --cask verda && brew install --cask orbly
```
