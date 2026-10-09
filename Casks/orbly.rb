# Orbly desktop app cask: the signed and notarized .app zips from GitHub Releases, one per arch
# (no DMG). The tap's Casks/orbly.rb is rendered from this template by update-tap.sh on every
# release (version and sha256 filled in), so edit it here, never in the tap.
# The app bundles the bot, the sandbox jobs and Electron's Node, so it needs no formula.
cask "orbly" do
  arch arm: "arm64", intel: "x64"

  version "0.2.0"
  sha256 arm:   "f45727186f7b2b02a9a592fed2863a82d1bf916ea0ad9eca607ea1e6f01da5d3",
         intel: "7dfcd00bd6bf7d4e51bb62a267d790e1892ba87b9620aeeeee01a702df084921"

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
      - open Orbly, fill in the Slack tokens in Settings > Slack, then build the
        sandbox images in Settings > Sandbox
    Config and run history are in ~/.orbly and are kept when the app is removed.
  EOS
end
