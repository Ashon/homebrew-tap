# supragnosis daemon/CLI formula (prebuilt release binaries; keyword + hashing search -
# build from source with --features fastembed for local semantic search).
# Lives in the tap repo as Formula/supragnosis.rb; update-tap.sh rewrites version/sha256
# per release from this template.
class Supragnosis < Formula
  desc "Embedded MCP server that grows an ontology from working knowledge"
  homepage "https://supragnosis.dev/"
  version "0.1.10"
  license any_of: ["MIT", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Ashon/supragnosis/releases/download/v#{version}/supragnosis-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "42e2fa585473d813fa4bcf289fa584b23dadde721a55e312e154506cea35a39d"
    else
      url "https://github.com/Ashon/supragnosis/releases/download/v#{version}/supragnosis-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "c1143052919580a1c6314b78c49aa41215e5f6ec65ba659ef3c8611ae9a97712"
    end
  end

  on_linux do
    url "https://github.com/Ashon/supragnosis/releases/download/v#{version}/supragnosis-v#{version}-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "818fe323d67343066cd23eb0c876be5da9b21ddd8ab39b002570ddcf2fed249f"
  end

  def install
    bin.install "supragnosis"
  end

  # brew services start supragnosis
  # `serve --http` also brings up the viewer unix socket at ~/.supragnosis/viz.sock by
  # default, which is what the desktop app (cask supragnosis-app) attaches to.
  service do
    run [opt_bin/"supragnosis", "serve", "--http", "127.0.0.1:7373"]
    keep_alive true
    log_path var/"log/supragnosis.log"
    error_log_path var/"log/supragnosis.err.log"
  end

  test do
    assert_match "supragnosis", shell_output("#{bin}/supragnosis --help")
  end
end
