require_relative "../lib/custom_download_strategy"

cask "tacit" do
  version "0.9.2"
  sha256 :no_check

  url "https://github.com/freetis/Tacit/releases/download/v#{version}/Tacit-#{version}.zip",
      using: CustomGitHubPrivateRepositoryReleaseDownloadStrategy
  name "Tacit"
  desc "A quiet layer underneath your typing on macOS"
  homepage "https://github.com/freetis/Tacit"

  depends_on macos: :sonoma

  app "Tacit.app"
  binary "#{appdir}/Tacit.app/Contents/MacOS/Tacit", target: "tacit"

  zap trash: [
    "~/.config/tacit",
    "~/Library/Application Support/com.freetis.tacit",
    "~/Library/Preferences/com.freetis.tacit.plist",
  ]
end
