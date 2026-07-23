# supragnosis daemon/CLI formula (prebuilt release binaries; keyword + hashing search -
# build from source with --features fastembed for local semantic search).
# Lives in the tap repo as Formula/supragnosis.rb; update-tap.sh rewrites version/sha256
# per release from this template.
class Supragnosis < Formula
  desc "Embedded MCP server that grows an ontology from working knowledge"
  homepage "https://supragnosis.dev/"
  version "0.1.9"
  license any_of: ["MIT", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Ashon/supragnosis/releases/download/v#{version}/supragnosis-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "e39ef6f7619c20959cb2eddf7d34558714757dea0ddd87161ae1c4c310018cfc"
    else
      url "https://github.com/Ashon/supragnosis/releases/download/v#{version}/supragnosis-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "c6e84f9efb2770dfbb46af8b48d42933df3e352121527204928829d0c2d7fdd0"
    end
  end

  on_linux do
    url "https://github.com/Ashon/supragnosis/releases/download/v#{version}/supragnosis-v#{version}-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "05242ec6754d0eb2b171082a66ff44083d67c4a1469bda4a5ac4d7c50b2879a9"
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
