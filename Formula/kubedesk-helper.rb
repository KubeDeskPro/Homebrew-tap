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
  desc "Helper service for KubeDesk - Exec-based auth for Kubernetes cloud providers"
  homepage "https://github.com/KubeDeskPro/kubedesk-helper"
  url "https://github.com/KubeDeskPro/kubedesk-helper/releases/download/v1.0.3/kubedesk-helper-1.0.3-arm64.tar.gz"
  sha256 "REPLACE_WITH_ACTUAL_SHA256_AFTER_BUILDING"
  version "1.0.3"
  license "MIT"

  depends_on :macos
  depends_on arch: :arm64

  def install
    bin.install "kubedesk-helper"
    
    # Install LaunchAgent plist
    (var/"log").mkpath
    
    # Create plist with correct paths
    plist_content = <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>Label</key>
          <string>com.kubedesk.helper</string>
          
          <key>ProgramArguments</key>
          <array>
              <string>#{bin}/kubedesk-helper</string>
          </array>
          
          <key>RunAtLoad</key>
          <true/>
          
          <key>KeepAlive</key>
          <true/>
          
          <key>StandardOutPath</key>
          <string>#{var}/log/kubedesk-helper.log</string>
          
          <key>StandardErrorPath</key>
          <string>#{var}/log/kubedesk-helper-error.log</string>
          
          <key>WorkingDirectory</key>
          <string>/tmp</string>
      </dict>
      </plist>
    EOS
    
    (buildpath/"com.kubedesk.helper.plist").write plist_content
  end

  service do
    run [opt_bin/"kubedesk-helper"]
    keep_alive true
    log_path var/"log/kubedesk-helper.log"
    error_log_path var/"log/kubedesk-helper-error.log"
    working_dir "/tmp"
  end

  test do
    # Test that the binary exists and is executable
    assert_predicate bin/"kubedesk-helper", :exist?
    assert_predicate bin/"kubedesk-helper", :executable?
  end
end

