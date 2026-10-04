# Desktop shell cask (signed + notarized universal .app zip from GitHub Releases - no DMG).
# Owns the plain `supragnosis` token: `brew install supragnosis` resolves here (no formula
# shares the name) and pulls the server formula via depends_on.
# The tap's Casks/supragnosis.rb is rendered from this template by update-tap.sh on every release.
# The shell attaches to (or spawns) the daemon from the supragnosis-server formula found on
# PATH, so the app bundle carries no sidecar binary.
cask "supragnosis" do
  version "0.4.5"
  sha256 "29424e994b1cabb2c70c77a820b5ee63fa2e0742884769a99336fcb374c1defa"

  url "https://github.com/Ashon/supragnosis/releases/download/v#{version}/Supragnosis-v#{version}-macos-universal.app.zip"
  name "Supragnosis"
  desc "Desktop shell for the supragnosis knowledge daemon"
  homepage "https://supragnosis.dev/"

  depends_on formula: "supragnosis-server"

  app "Supragnosis.app"

  # Tray-resident app: brew never quits a running instance on uninstall/upgrade, which
  # leaves the old process serving from a deleted bundle. quit is upgrade-aware (brew
  # reopens the app after the swap).
  uninstall quit: "dev.supragnosis.desktop"

  zap trash: [
    "~/Library/Caches/dev.supragnosis.desktop",
    "~/Library/WebKit/dev.supragnosis.desktop",
  ]
end
