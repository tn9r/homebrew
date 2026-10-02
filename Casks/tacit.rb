require_relative "../lib/custom_download_strategy"

cask "tacit" do
  version "0.12.1"
  sha256 :no_check

  url "https://github.com/freetis/Tacit/releases/download/v#{version}/Tacit-#{version}.zip",
      using: CustomGitHubPrivateRepositoryReleaseDownloadStrategy
  name "Tacit"
  desc "A quiet layer underneath your typing on macOS"
  homepage "https://github.com/freetis/Tacit"

  depends_on macos: :sonoma

  preflight_steps do
    run "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.freetis.tacit"], must_succeed: false
    terminate_process "Tacit", match: :name, must_succeed: false
  end

  app "Tacit.app"
  binary "#{appdir}/Tacit.app/Contents/MacOS/Tacit", target: "tacit"

  postflight_steps do
    run "{{appdir}}/Tacit.app/Contents/MacOS/Tacit", args: ["install"], must_succeed: false
  end

  uninstall launchctl: "com.freetis.tacit",
            quit:      "com.freetis.tacit"

  zap trash: [
    "~/.config/tacit",
    "~/Library/Application Support/com.freetis.tacit",
    "~/Library/Preferences/com.freetis.tacit.plist",
  ]
end
