require "download_strategy"

class CustomGitHubPrivateRepositoryDownloadStrategy < CurlDownloadStrategy
  require "utils/formatter"
  require "utils/github"

  def initialize(url, name, version, **meta)
    super
    parse_url_pattern
    set_github_token
  end

  def parse_url_pattern
    unless match = url.match(%r{https://github.com/([^/]+)/([^/]+)/(\S+)})
      raise CurlDownloadStrategyError, "Invalid url pattern for GitHub Repository."
    end

    _, @owner, @repo, @filepath = *match
  end

  def download_url
    "https://github.com/#{@owner}/#{@repo}/#{@filepath}"
  end

  private

  def _fetch(url:, resolved_url:, timeout: nil, **options)
    curl_download download_url, "--header", "Authorization: token #{@github_token}",
                                to: temporary_path, timeout: timeout, **options
  end

  def set_github_token
    @github_token = ENV["HOMEBREW_GITHUB_API_TOKEN"] || ENV["GITHUB_TOKEN"]

    # Fallback 1: read from macOS Keychain (where gh auth stores it on macOS)
    if @github_token.to_s.empty?
      keychain_out = `/usr/bin/security find-generic-password -s "gh:github.com" -w 2>/dev/null`.strip
      if keychain_out.start_with?("go-keyring-base64:")
        b64 = keychain_out.sub("go-keyring-base64:", "")
        @github_token = b64.unpack1("m").strip
      elsif !keychain_out.empty?
        @github_token = keychain_out
      end
    end

    # Fallback 2: try `gh auth token` via login shell or common paths
    if @github_token.to_s.empty?
      for gh_cmd in ["/opt/homebrew/bin/gh", "/usr/local/bin/gh", File.expand_path("~/.local/bin/gh")]
        if File.executable?(gh_cmd)
          t = `#{gh_cmd} auth token 2>/dev/null`.strip
          if !t.empty?
            @github_token = t
            break
          end
        end
      end
    end

    if @github_token.to_s.empty?
      raise CurlDownloadStrategyError, "HOMEBREW_GITHUB_API_TOKEN or GitHub CLI authentication (gh auth login) is required."
    end
  end
end

class CustomGitHubPrivateRepositoryReleaseDownloadStrategy < CustomGitHubPrivateRepositoryDownloadStrategy
  require "net/http"

  def initialize(url, name, version, **meta)
    super
  end

  def parse_url_pattern
    url_pattern = %r{https://github.com/([^/]+)/([^/]+)/releases/download/([^/]+)/(\S+)}
    unless @url =~ url_pattern
      raise CurlDownloadStrategyError, "Invalid url pattern for GitHub Release."
    end

    _, @owner, @repo, @tag, @filename = *@url.match(url_pattern)
  end

  def download_url
    uri = URI("https://api.github.com/repos/#{@owner}/#{@repo}/releases/assets/#{asset_id}")
    req = Net::HTTP::Get.new(uri)
    req["Accept"] = "application/octet-stream"
    req["Authorization"] = "token #{@github_token}"

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(req)
    end

    res["location"] || uri.to_s
  end

  private

  def _fetch(url:, resolved_url:, timeout: nil, **options)
    curl_download download_url, "--header", "Accept: application/octet-stream",
                                "--header", "Authorization: token #{@github_token}",
                                to: temporary_path, timeout: timeout, **options
  end

  def asset_id
    @asset_id ||= resolve_asset_id
  end

  def resolve_asset_id
    release_metadata = GitHub.get_release(@owner, @repo, @tag)
    assets = release_metadata["assets"].select { |a| a["name"] == @filename }
    raise CurlDownloadStrategyError, "Asset '#{@filename}' not found in release '#{@tag}'." if assets.empty?

    assets.first["id"]
  end
end
