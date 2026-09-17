require_relative "../custom_download_strategy"

cask "medify" do
  version "1.0.0"
  sha256 :no_check

  url "https://github.com/tn9r/medify/releases/download/v#{version}/Medify-#{version}.zip",
      using: CustomGitHubPrivateRepositoryReleaseDownloadStrategy
  name "Medify"
  desc "Personal media center & podcast library for macOS"
  homepage "https://github.com/tn9r/medify"

  depends_on macos: ">= :sonoma"

  app "Medify.app"

  zap trash: [
    "~/Library/Application Support/com.podify.app",
    "~/Library/Preferences/com.podify.app.plist",
  ]
end
