# Rendered by .github/workflows/release.yml into donePM/homebrew-tap as Formula/donepm.rb.
# 0.2.0 and 94ca96082ebae6cf19e1e1158374cf1c16538f24337963be32525f05041be3d9 are replaced there; edit this template, not the tap's copy.
class Donepm < Formula
  desc "Local board that runs a coding agent per issue and drafts every outward action"
  homepage "https://github.com/donePM/donepm"
  url "https://github.com/donePM/donepm/releases/download/v0.2.0/donepm-0.2.0.tar.gz"
  sha256 "94ca96082ebae6cf19e1e1158374cf1c16538f24337963be32525f05041be3d9"

  depends_on :macos
  depends_on "node"

  def install
    # The tarball is `pnpm deploy --prod` of the cli: dist/, package.json, node_modules/.
    libexec.install Dir["*"]
    # tsc does not set the executable bit; the wrapper below execs the file directly.
    chmod 0755, libexec/"dist/main.js"
    # `opt` paths survive `brew upgrade`, so the launchd job that `donepm install-service`
    # writes keeps pointing at the current version and the current Node.
    (bin/"donepm").write_env_script libexec/"dist/main.js",
      PATH:                "#{Formula["node"].opt_bin}:$PATH",
      DONEPM_NODE:         Formula["node"].opt_bin/"node",
      DONEPM_DAEMON_ENTRY: opt_libexec/"node_modules/@donepm/daemon/dist/index.js"
  end

  def caveats
    <<~EOS
      donePM needs `git`, the `gh` CLI logged in (`gh auth login`) and the `claude` CLI logged in.

      Start it now and at every login:
        donepm install-service
      Or in the foreground:
        donepm start

      After `brew upgrade donepm`, run `donepm install-service` again to restart on the new version.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/donepm --version")
  end
end
