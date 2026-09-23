require_relative "../lib/custom_download_strategy"

cask "kinetic" do
  version "0.6.0"
  sha256 :no_check

  url "https://github.com/narrino/kinetic/releases/download/v#{version}/Kinetic-#{version}.zip",
      using: CustomGitHubPrivateRepositoryReleaseDownloadStrategy
  name "Kinetic"
  desc "Pure Swift motion graphics studio for macOS"
  homepage "https://github.com/narrino/kinetic"

  depends_on macos: :sonoma

  app "Kinetic.app"
  binary "#{appdir}/Kinetic.app/Contents/Helpers/kinetic", target: "kinetic"

  zap trash: [
    "~/Library/Application Support/com.kinetic.studio",
    "~/Library/Caches/Kinetic",
    "~/Library/Preferences/com.kinetic.studio.plist",
  ]
end
