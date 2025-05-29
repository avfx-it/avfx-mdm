cask "deskflow" do
  version :latest
  sha256 :no_check

  url do
    require "open-uri"
    require "json"

    releases = JSON.parse(URI.open("https://api.github.com/repos/deskflow/deskflow/releases/latest").read)
    asset = releases["assets"].find { |a| a["name"].include?("macos-arm64.dmg") }
    asset["browser_download_url"]
  end

  name "Deskflow"
  desc "AI assistant for customer support"
  homepage "https://github.com/deskflow/deskflow"

  app "Deskflow.app"

  zap trash: [
    "~/Library/Application Support/Deskflow",
    "~/Library/Preferences/com.deskflow.Deskflow.plist",
  ]
end
