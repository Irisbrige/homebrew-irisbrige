class Irisbrige < Formula
  desc "Local macOS relay for iOS and Codex App Server RPC"
  homepage "https://github.com/Irisbrige/homebrew-irisbrige"
  version "0.6.0"

  if Hardware::CPU.arm?
    url "https://github.com/Irisbrige/homebrew-irisbrige/releases/download/v0.6.0/irisbrige-edge_0.6.0_darwin_arm64.tar.gz"
    sha256 "f551c4387727f91b615f7b5f896824c3c0703393d5902c0b700445a431b511ac"
  else
    url "https://github.com/Irisbrige/homebrew-irisbrige/releases/download/v0.6.0/irisbrige-edge_0.6.0_darwin_amd64.tar.gz"
    sha256 "6bd1e40a91b790a66ddfd8c2b6a4b017f2dff505d683be2f0594e0f4a2845444"
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
