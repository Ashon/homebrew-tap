# supragnosis server/CLI formula (prebuilt release binaries, with local semantic retrieval: the
# model is fetched once by `supragnosis service install` or `supragnosis embed fetch`).
# The tap's Formula/supragnosis-server.rb is rendered from this template by update-tap.sh on every
# release (version and sha256 filled in), so edit it here, never in the tap. Installs the plain
# `supragnosis` binary - only the brew token carries the -server suffix (the desktop-app cask owns
# the plain `supragnosis` token).
class SupragnosisServer < Formula
  desc "Embedded MCP server that grows an ontology from working knowledge"
  homepage "https://supragnosis.dev/"
  version "0.6.5"
  license any_of: ["MIT", "Apache-2.0"]

  # Bottles, rendered here by update-tap.sh from the ones the release built (deploy/homebrew/README.md).
  # This formula only copies a prebuilt binary, but without a bottle Homebrew treats any formula as a
  # source build and refuses to install it without an up-to-date Xcode or Command Line Tools.
  bottle do
    root_url "https://github.com/Ashon/supragnosis/releases/download/v0.6.5"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "2e67d6a176c8e6f4cc1922b324783c85c34a90fb4077353b9316edda68f114d0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c0633f2690d9f17f72e361a94b65d689e4c11ca3c154ef61edc19d1263f3ee8f"
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
      sha256 "c277433375d86b116425329dc76300760d1ff44b127b50feacf79204e0b312aa"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Ashon/supragnosis/releases/download/v#{version}/supragnosis-v#{version}-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "4de04094813ebfccaee97c09430351d6496bae811e856c7fea4aade9e2f9a5fc"
    end
    on_intel do
      url "https://github.com/Ashon/supragnosis/releases/download/v#{version}/supragnosis-v#{version}-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "6fa34ab9ca5d3570b613a6ebe342b22cdfb039df2d48c56acc10332020d13ba6"
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
