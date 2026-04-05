class Irisbrige < Formula
  desc "Local macOS relay for iOS and Codex App Server RPC"
  homepage "https://github.com/Irisbrige/homebrew-irisbrige"
  version "0.5.0"

  if Hardware::CPU.arm?
    url "https://github.com/Irisbrige/homebrew-irisbrige/releases/download/v0.5.0/irisbrige-edge_0.5.0_darwin_arm64.tar.gz"
    sha256 "1e3ec874bacc705666bcd9d1b8dc98917eec1e951ddf0af6a8aef33a00449361"
  else
    url "https://github.com/Irisbrige/homebrew-irisbrige/releases/download/v0.5.0/irisbrige-edge_0.5.0_darwin_amd64.tar.gz"
    sha256 "2aed7f31428a624f21658b9c555bfacf19a52da13669c5d9191f3f6c14873b1e"
  end

  def install
    bin.install "irisbrige-edge"
  end

  service do
    run [opt_bin/"irisbrige-edge", "server"]
    keep_alive true
    process_type :background
    environment_variables PATH: std_service_path_env
    log_path var/"log/irisbrige.log"
    error_log_path var/"log/irisbrige.error.log"
  end

  def caveats
    <<~EOS
      Homebrew formulae cannot auto-start `brew services` during `brew install`.

      The executable is installed as:
        irisbrige-edge

      Start the background service manually with:
        brew services start irisbrige

      The service runs:
        irisbrige-edge server

      Logs are written to:
        #{var}/log/irisbrige.log
        #{var}/log/irisbrige.error.log

      Runtime expects the `codex` CLI to be available on PATH.
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/irisbrige-edge --help")
  end
end
