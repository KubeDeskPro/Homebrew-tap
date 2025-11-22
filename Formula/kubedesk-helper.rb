# Homebrew Formula for KubeDesk Helper
#
# This formula should be published to: KubeDeskPro/homebrew-tap
# Repository: https://github.com/KubeDeskPro/homebrew-tap
# Location: Formula/kubedesk-helper.rb
#
# Users install with:
#   brew tap kubedeskpro/tap
#   brew install kubedesk-helper

class KubedeskHelper < Formula
  desc "Helper service for KubeDesk - Kubernetes management for macOS"
  homepage "https://github.com/kubedeskpro/kubedesk-helper"
  url "https://github.com/kubedeskpro/kubedesk-helper/releases/download/v2.1.1/kubedesk-helper-2.1.1.tar.gz"
  sha256 "41d0c61cfb0ec086a47aa83acd0ad075838a72447b8afe6a74e55464ab9e69a6"
  version "2.1.1"
  license "MIT"

  depends_on :macos

  def install
    # Install the pre-built binary
    bin.install "kubedesk-helper"

    # Create log directory
    (var/"log/kubedesk-helper").mkpath
  end

  service do
    run [opt_bin/"kubedesk-helper"]
    keep_alive true
    log_path var/"log/kubedesk-helper/stdout.log"
    error_log_path var/"log/kubedesk-helper/stderr.log"
    environment_variables PATH: std_service_path_env
  end

  def caveats
    <<~EOS
      KubeDesk Helper v2.1.1 has been installed!

      To start the helper service now and restart at login:
        brew services start kubedesk-helper

      Or, if you don't want/need a background service:
        #{opt_bin}/kubedesk-helper

      The helper runs on port 47823 and provides:
        - kubectl command execution
        - Exec-based authentication (AWS EKS, GCP GKE, Azure AKS)
        - Port-forwarding sessions
        - Exec into pods
        - kubectl proxy

      Logs are available at:
        #{var}/log/kubedesk-helper/

      Test the helper:
        curl http://localhost:47823/health
    EOS
  end

  test do
    # Start the helper in background
    pid = fork do
      exec bin/"kubedesk-helper"
    end

    sleep 2

    # Test health endpoint
    output = shell_output("curl -s http://localhost:47823/health")
    assert_match "2.1.1", output
    assert_match "ok", output

    # Clean up
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end

