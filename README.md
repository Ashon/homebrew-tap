# supragnosis Homebrew tap

Embedded MCP server that grows an ontology from working knowledge -
https://supragnosis.dev/ (source: https://github.com/Ashon/supragnosis)

## Install

```sh
brew tap ashon/tap
brew install supragnosis            # daemon / CLI (prebuilt binary)
brew services start supragnosis     # always-on daemon: MCP http://127.0.0.1:7373/mcp
                                    # + viewer socket ~/.supragnosis/viz.sock
```

Register with an MCP client, e.g. Claude Code:

```sh
claude mcp add supragnosis --transport http http://127.0.0.1:7373/mcp
```

## Desktop app (cask)

`brew install --cask supragnosis-app` ships with the first release that attaches the
signed universal .app bundle (the cask depends on the formula above - the app attaches
to the brew-managed daemon).

## Notes

- The prebuilt binary uses keyword + hashing search. For local ONNX semantic search,
  build from source with `--features fastembed`.
- Release checksums come from the .sha256 sidecars published on each GitHub release;
  update-tap.sh in this repo rewrites the version/sha lines per release.
