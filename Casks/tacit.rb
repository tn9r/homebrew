require_relative "../lib/custom_download_strategy"

cask "tacit" do
  version "0.12.0"
  sha256 :no_check

  url "https://github.com/freetis/Tacit/releases/download/v#{version}/Tacit-#{version}.zip",
      using: CustomGitHubPrivateRepositoryReleaseDownloadStrategy
  name "Tacit"
  desc "A quiet layer underneath your typing on macOS"
  homepage "https://github.com/freetis/Tacit"

  depends_on macos: :sonoma

  preflight do
    # Stop the running LaunchAgent and kill any active process before the bundle is replaced
    system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.freetis.tacit"], print_stderr: false
    system_command "/usr/bin/pkill", args: ["-9", "-f", "#{appdir}/Tacit.app/Contents/MacOS/Tacit"], print_stderr: false
  end

  app "Tacit.app"
  binary "#{appdir}/Tacit.app/Contents/MacOS/Tacit", target: "tacit"

  postflight do
    # Restart the background service with the newly installed binary
    system_command "#{appdir}/Tacit.app/Contents/MacOS/Tacit", args: ["install"], print_stderr: false
  end

  uninstall launchctl: "com.freetis.tacit",
            quit:      "com.freetis.tacit"

  zap trash: [
    "~/.config/tacit",
    "~/Library/Application Support/com.freetis.tacit",
    "~/Library/Preferences/com.freetis.tacit.plist",
  ]
end
