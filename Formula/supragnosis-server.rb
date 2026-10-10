# supragnosis server/CLI formula (prebuilt release binaries; keyword + hashing search -
# build from source with --features fastembed for local semantic search).
# The tap's Formula/supragnosis-server.rb is rendered from this template by update-tap.sh on every
# release (version and sha256 filled in), so edit it here, never in the tap. Installs the plain
# `supragnosis` binary - only the brew token carries the -server suffix (the desktop-app cask owns
# the plain `supragnosis` token).
class SupragnosisServer < Formula
  desc "Embedded MCP server that grows an ontology from working knowledge"
  homepage "https://supragnosis.dev/"
  version "0.4.11"
  license any_of: ["MIT", "Apache-2.0"]

  # Bottles, rendered here by update-tap.sh from the ones the release built (deploy/homebrew/README.md).
  # This formula only copies a prebuilt binary, but without a bottle Homebrew treats any formula as a
  # source build and refuses to install it without an up-to-date Xcode or Command Line Tools.
  bottle do
    root_url "https://github.com/Ashon/supragnosis/releases/download/v0.4.11"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "9ca4880a367702708d92c18ea8c8f242029e613a203c5d0ef16ae98799486adb"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "2104ad065ad7dfa067cb02ff707a2bca206eb1df4414c88c883a20369d8618b9"
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Ashon/supragnosis/releases/download/v#{version}/supragnosis-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "52f9fcc0553cb92b2f25c666debd4ccbef71083f09def9f0e824684ec35f4dbf"
    else
      url "https://github.com/Ashon/supragnosis/releases/download/v#{version}/supragnosis-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "a250e22ced6b5468832175446d9a41f2e32bf6dbfeb89ae7f093b238bef149d5"
    end
  end

  on_linux do
    url "https://github.com/Ashon/supragnosis/releases/download/v#{version}/supragnosis-v#{version}-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "18a19e30173e46a5be33e15fb9308276119823757f34debd4a1dc799fba319fb"
  end

  # Dev channel: `brew install --HEAD supragnosis-server` builds current main from source
  # (rust toolchain pulled as a build dep; default features = keyword search, same as the
  # release binaries). Refresh an installed HEAD with `brew upgrade --fetch-HEAD`.
  head do
    url "https://github.com/Ashon/supragnosis.git", branch: "main"
    depends_on "rust" => :build
  end

  def install
    if build.head?
      system "cargo", "install", *std_cargo_args(path: "crates/supragnosis-cli")
    else
      bin.install "supragnosis"
    end
  end

  # No `service do` block, deliberately. The always-on daemon has ONE manager - the canonical
  # LaunchAgent com.supragnosis.daemon, installed by `supragnosis service install` or the desktop
  # app's Start at Login (docs/daemon-lifecycle.md). A brew services job beside it is a second owner
  # of a single-writer store: it fails on the lock and KeepAlive retries it forever, unreported.
  # An existing brew services job keeps running after this upgrade; `supragnosis status` reports
  # it and `supragnosis service install --take-over` migrates it.
  def caveats
    <<~EOS
      Run the daemon now and at every login (MCP on 127.0.0.1:7373 + the viewer socket):
        supragnosis service install
      or turn on Start at Login in the Supragnosis app (brew install --cask supragnosis).

      Coming from `brew services start supragnosis-server`:
        supragnosis service install --take-over

      After an upgrade, load the new binary into the running daemon:
        supragnosis restart
    EOS
  end

  test do
    assert_match "supragnosis", shell_output("#{bin}/supragnosis --help")
  end
end
