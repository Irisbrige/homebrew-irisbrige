class Scrollcode < Formula
    desc "Local macOS relay for iOS and Codex App Server RPC"
    homepage "https://github.com/ScrollCode-App/homebrew-scrollcode"
    version "0.1.1"

    on_macos do
      on_arm do
        url "https://github.com/ScrollCode-App/homebrew-scrollcode/releases/download/v0.1.1/ScrollCode_0.1.1_darwin_arm64.tar.gz"
        sha256 "50ab30c22e6480ab7bfd20bfec203f024ecf8624809f5c0845db9a0da5420380"
      end

      on_intel do
        url "https://github.com/ScrollCode-App/homebrew-scrollcode/releases/download/v0.1.1/ScrollCode_0.1.1_darwin_amd64.tar.gz"
        sha256 "742fec6f88a2be4b7b2152c90caa597d01b764d3dab65ecbcc509c7ab9181683"
      end
    end

    def install
      bin.install "ScrollCode" => "ScrollCode"
    end

    def caveats
      <<~EOS
        The executable is installed as:
          ScrollCode

        Default runtime expects the `codex` CLI to be available on PATH.
      EOS
    end

    test do
      assert_predicate bin/"ScrollCode", :exist?
    end
  end
