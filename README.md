# Ashon's Homebrew tap

| Token | Kind | What |
| --- | --- | --- |
| `supragnosis` | cask | supragnosis desktop app (pulls `supragnosis-server`) |
| `supragnosis-dev` | cask | supragnosis desktop app, rolling dev build |
| `supragnosis-server` | formula | supragnosis server / CLI |
| `pacenote` | cask | Pacenote desktop app (Slack bot on local claude/codex CLIs), formerly `orbly` and `verda` |

```sh
brew tap ashon/tap
```

The formula and casks here are rendered output: each project's release overwrites them from the
templates in its own `deploy/homebrew` directory, so a change is made there, never in this repo.

- supragnosis: https://github.com/Ashon/supragnosis/tree/main/deploy/homebrew
- pacenote: https://github.com/Ashon/pacenote/tree/main/deploy/homebrew

## supragnosis

Embedded MCP server that grows an ontology from working knowledge -
https://supragnosis.dev/ (source: https://github.com/Ashon/supragnosis)

### Install

```sh
brew tap ashon/tap
brew install supragnosis                # desktop app (macOS) - pulls the server formula with it
brew install supragnosis-server         # server / CLI only (macOS / Linux, prebuilt binary)
supragnosis service install             # always-on daemon, now and at every login:
                                        # MCP http://127.0.0.1:7373/mcp + viewer socket ~/.supragnosis/viz.sock
```

The installed binary is named `supragnosis` either way - only the brew tokens differ.
`supragnosis` is the desktop-app cask; it depends on the `supragnosis-server` formula,
and the app attaches to the brew-installed daemon on PATH (no bundled sidecar). Instead of
`supragnosis service install`, you can turn on Start at Login in the app.

The formula has no `service do` block on purpose, so `brew services` does not manage the daemon:
it has one manager, the login job that `supragnosis service install` (or Start at Login) creates.

Upgrading takes two commands - `brew upgrade` swaps the binaries and relaunches the
app, but it does not restart a running daemon (the formula caveats print the same
reminder). Without the restart the old daemon keeps running from the deleted keg:

```sh
brew upgrade
supragnosis restart
```

Register with an MCP client, e.g. Claude Code:

```sh
claude mcp add supragnosis --transport http http://127.0.0.1:7373/mcp
```

### Dev channel

```sh
brew install --HEAD supragnosis-server     # server built from main (rust is pulled as a build dep)
brew uninstall --cask supragnosis && brew install --cask supragnosis-dev   # rolling dev app
brew reinstall supragnosis-dev             # brew upgrade does not track it (version :latest)
```

`supragnosis-dev` conflicts with `supragnosis` (same app bundle). See the supragnosis
deploy/homebrew README for swapping between stable and dev.

### Migrating from brew services

Before v0.4.3 the formula had a service block and this README said `brew services start
supragnosis-server`. That job keeps running after an upgrade (`supragnosis status` names it);
move it to the login job once:

```sh
supragnosis service install --take-over
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
- The formula ships bottles for Apple silicon on macOS 14+ (`arm64_sonoma`) and x86_64 Linux.
  Intel Macs have none, so Homebrew takes its source-build path there and requires up-to-date
  Command Line Tools (`xcode-select --install`), even though it only copies the prebuilt binary.

## pacenote

You drive, Pace reads the notes: a Slack bot that answers mentions with your local claude or codex CLI,
run in a Docker sandbox - https://github.com/Ashon/pacenote. The cask installs the signed and notarized
Pacenote.app (Apple silicon or Intel, macOS 12+); the app carries the bot, so there is no formula.

```sh
brew install --cask pacenote
brew upgrade --cask pacenote     # quits the running app first (the bot finishes its requests), then reopens it
```

The cask caveats list the first-run steps (Docker, claude/codex login, Slack, sandbox images).
Config, run history and the sandbox allowlist live in `~/.pacenote` and are kept on upgrade and
uninstall; `--zap` removes the app's Library folders, still not `~/.pacenote`.

### Migrating from orbly / verda

The cask was `verda` until v0.1.2 and `orbly` until v0.2.2. `cask_renames.json` maps both to `pacenote`,
so `brew update && brew upgrade` moves an existing install over to Pacenote.app. If brew keeps listing
the old token:

```sh
brew uninstall --cask orbly && brew install --cask pacenote   # or verda
```

Since v0.3.12 Pacenote reads nothing from before the renames. If your settings are still in `~/.orbly`
or `~/.verda`, move them and rename the `ORBLY_*` / `VERDA_*` keys in `~/.pacenote/.env` to `PACENOTE_*`:

```sh
mv ~/.orbly ~/.pacenote   # or ~/.verda
```
