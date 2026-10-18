# supragnosis server/CLI formula (prebuilt release binaries, with local semantic retrieval: the
# model is fetched once by `supragnosis service install` or `supragnosis embed fetch`).
# The tap's Formula/supragnosis-server.rb is rendered from this template by update-tap.sh on every
# release (version and sha256 filled in), so edit it here, never in the tap. Installs the plain
# `supragnosis` binary - only the brew token carries the -server suffix (the desktop-app cask owns
# the plain `supragnosis` token).
class SupragnosisServer < Formula
  desc "Embedded MCP server that grows an ontology from working knowledge"
  homepage "https://supragnosis.dev/"
  version "0.6.3"
  license any_of: ["MIT", "Apache-2.0"]

  # Bottles, rendered here by update-tap.sh from the ones the release built (deploy/homebrew/README.md).
  # This formula only copies a prebuilt binary, but without a bottle Homebrew treats any formula as a
  # source build and refuses to install it without an up-to-date Xcode or Command Line Tools.
  bottle do
    root_url "https://github.com/Ashon/supragnosis/releases/download/v0.6.3"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "bd41d254f8be94b1731e0f55ce84123d99a84db45ce88e6859c29a8a08c4932a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "067922cb0d4c489f11b10eb2d0fe6c1662462efb5b0d82089ae0f1bbcc102aa4"
  end

  # Dev channel: `brew install --HEAD supragnosis-server` builds current main from source
  # (rust toolchain pulled as a build dep; default features = keyword search, same as the
  # release binaries). Refresh an installed HEAD with `brew upgrade --fetch-HEAD`.
  head do
    url "https://github.com/Ashon/supragnosis.git", branch: "main"
    depends_on "rust" => :build
  end

  # One release tarball per OS and arch, each named for its target triple. on_arm / on_intel, not
  # `if Hardware::CPU.arm?`: brew resolves them for whichever platform it is asked about, not only
  # the machine it runs on. Linux once had a single url, so arm64 Linux installed the x86_64 binary.
  # macOS is Apple silicon only: the release builds no Intel Mac binary, so an Intel Mac is refused
  # with that reason and builds from source instead (deploy/homebrew/README.md).
  on_macos do
    depends_on arch: :arm64
    on_arm do
      url "https://github.com/Ashon/supragnosis/releases/download/v#{version}/supragnosis-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "fb79da02373ec544d883b9b33084ec9275537842efbf34130c160ca41a3fe916"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Ashon/supragnosis/releases/download/v#{version}/supragnosis-v#{version}-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "f7f011b4c313261b27415ba3f67c50cc6a626304c97284ed9129a43b032b0b31"
    end
    on_intel do
      url "https://github.com/Ashon/supragnosis/releases/download/v#{version}/supragnosis-v#{version}-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "dc8a4abdf2140783c0e3ecffcdf77019298dacea02543589f936bd8eab71d37b"
    end
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

      Semantic retrieval needs the embedding model, fetched once (224 MB):
        supragnosis embed fetch
      The running daemon finds it within 30 seconds and embeds what it already holds;
      `supragnosis status` shows the progress.
    EOS
  end

  test do
    assert_match "supragnosis", shell_output("#{bin}/supragnosis --help")
  end
end
