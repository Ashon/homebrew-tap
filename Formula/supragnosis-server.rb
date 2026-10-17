# supragnosis server/CLI formula (prebuilt release binaries, with local semantic retrieval: the
# model is fetched once by `supragnosis service install` or `supragnosis embed fetch`).
# The tap's Formula/supragnosis-server.rb is rendered from this template by update-tap.sh on every
# release (version and sha256 filled in), so edit it here, never in the tap. Installs the plain
# `supragnosis` binary - only the brew token carries the -server suffix (the desktop-app cask owns
# the plain `supragnosis` token).
class SupragnosisServer < Formula
  desc "Embedded MCP server that grows an ontology from working knowledge"
  homepage "https://supragnosis.dev/"
  version "0.6.0"
  license any_of: ["MIT", "Apache-2.0"]

  # Bottles, rendered here by update-tap.sh from the ones the release built (deploy/homebrew/README.md).
  # This formula only copies a prebuilt binary, but without a bottle Homebrew treats any formula as a
  # source build and refuses to install it without an up-to-date Xcode or Command Line Tools.
  bottle do
    root_url "https://github.com/Ashon/supragnosis/releases/download/v0.6.0"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "1ca4773ea8755e124f631c9af914d0deec300170165eb55e19428abfce7d4af4"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "7aea8951950615810779a2ac92e2d6f0c31101a6c8f68755e640f51052399355"
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
      sha256 "4b5326f42e06ec92d3aebb4233accb3d8affe6ee7931d447aff215991c55cd3f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Ashon/supragnosis/releases/download/v#{version}/supragnosis-v#{version}-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "f9ac9595222761035a2455bb5bb9d58913f531ad5ac7492a8acb0229e9f90b7a"
    end
    on_intel do
      url "https://github.com/Ashon/supragnosis/releases/download/v#{version}/supragnosis-v#{version}-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "f34e366f54dcbde60644856b3cd80ef6bf7784803cd6c22a6e7d1c4c5cc083c9"
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
