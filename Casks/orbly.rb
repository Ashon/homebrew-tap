# Orbly desktop app cask: the signed and notarized .app zips from GitHub Releases, one per arch
# (no DMG). The tap's Casks/orbly.rb is rendered from this template by update-tap.sh on every
# release (version and sha256 filled in), so edit it here, never in the tap.
# The app bundles the bot, the sandbox jobs and Electron's Node, so it needs no formula.
cask "orbly" do
  arch arm: "arm64", intel: "x64"

  version "0.2.2"
  sha256 arm:   "6bb0dbc081ae63628a0ca6a21fa2570a145248d3f2c551c0e3a39d6a11c7c5c0",
         intel: "6f51c6b31d0780ae2e6cbf7f6a8bd01ebcabeb9b87ad9821ee2fd998c778aef8"

  url "https://github.com/Ashon/orbly/releases/download/v#{version}/Orbly-v#{version}-macos-#{arch}.app.zip"
  name "Orbly"
  desc "Slack bot that answers mentions with local claude or codex CLIs in a sandbox"
  homepage "https://github.com/Ashon/orbly"

  # Electron 38 and later need macOS 12.
  depends_on macos: :monterey

  app "Orbly.app"

  # Tray-resident app: brew never quits a running instance on uninstall or upgrade, which would
  # leave the old process (and the bot it supervises) running from a deleted bundle. quit is
  # upgrade-aware: brew reopens the app after the swap. Quitting lets the bot finish its requests.
  uninstall quit: "io.github.ashon.orbly"

  # Config, run history and the sandbox allowlist live in ~/.orbly (ORBLY_HOME) and are kept.
  zap trash: [
    "~/Library/Application Support/Orbly",
    "~/Library/Caches/io.github.ashon.orbly",
    "~/Library/HTTPStorages/io.github.ashon.orbly",
    "~/Library/Preferences/io.github.ashon.orbly.plist",
    "~/Library/Saved Application State/io.github.ashon.orbly.savedState",
  ]

  caveats <<~EOS
    Orbly runs each answer in a Docker sandbox and uses your local claude or codex CLI login.
    Before the first mention:
      - run Docker (Docker Desktop, OrbStack or colima)
      - log in to claude or codex
      - open Orbly, connect Slack in Settings > Slack (pair with your team's hub, or enter
        your own Slack app's tokens), then build the sandbox images in Settings > Sandbox
    Config and run history are in ~/.orbly and are kept when the app is removed.
    Coming from Verda: Orbly keeps using ~/.verda until you move it to ~/.orbly.
  EOS
end
