class Scrollcode < Formula
    desc "Local macOS relay for iOS and Codex App Server RPC"
    homepage "https://github.com/ScrollCode-App/homebrew-scrollcode"
    version "0.2.0"

    on_macos do
      on_arm do
        url "https://github.com/ScrollCode-App/homebrew-scrollcode/releases/download/v0.2.0/ScrollCode_0.2.0_darwin_arm64.tar.gz"
        sha256 "d466a7c8db79ab8a935c9105c248f3fe0799e09fe8e2559fd6afb5807cb34752"
      end

      on_intel do
        url "https://github.com/ScrollCode-App/homebrew-scrollcode/releases/download/v0.2.0/ScrollCode_0.2.0_darwin_amd64.tar.gz"
        sha256 "a8fe94a2b43b871993baa407a40225e94cf4a041e7eabf8ec892742eb1eb7534"
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
