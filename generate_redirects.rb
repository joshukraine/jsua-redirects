#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

# Load the redirects configuration
config_file = "redirects.yaml"
unless File.exist?(config_file)
  puts "Error: #{config_file} not found!"
  exit 1
end

config = YAML.load_file(config_file)

# Generate the _redirects file
File.open("_redirects", "w") do |file|
  # Header
  file.puts "# jsua.co URL Redirects"
  file.puts "# Format: /path https://destination-url status-code"
  file.puts

  # Root domain redirect if specified
  if config["root"]
    file.puts "# Root domain redirect"
    root = config["root"]
    status = root["status"] || 301
    file.puts "/ #{root["url"]} #{status}"
    file.puts
  end

  # Collect all paths for trailing slash redirects
  redirects = config["redirects"] || []

  if redirects.any?
    # Trailing slash redirects section
    file.puts "# Trailing slash redirects (handle URLs with trailing slashes)"
    redirects.each do |redirect|
      path = redirect["path"]
      file.puts "/#{path}/ /#{path} 301"
    end
    file.puts

    # Group redirects by category (personal vs business)
    personal_redirects = []
    business_redirects = []

    redirects.each do |redirect|
      if redirect["category"] == "business"
        business_redirects << redirect
      else
        personal_redirects << redirect
      end
    end

    # Personal/Development Links
    if personal_redirects.any?
      file.puts "# Personal/Development Links"
      personal_redirects.each do |redirect|
        path = redirect["path"]
        url = redirect["url"]
        status = redirect["status"] || 301
        file.puts "/#{path} #{url} #{status}"
      end
      file.puts
    end

    # Business/Professional Links
    if business_redirects.any?
      file.puts "# Business/Professional Links"
      business_redirects.each do |redirect|
        path = redirect["path"]
        url = redirect["url"]
        status = redirect["status"] || 301
        file.puts "/#{path} #{url} #{status}"
      end
      file.puts
    end
  end

  # Footer
  file.puts "# Add new redirects above this line"
  file.puts
  file.puts "# vim: set filetype=apache:"
  file.puts
end

puts "✅ Generated _redirects file successfully!"
puts "📝 Total redirects: #{config["redirects"]&.length || 0}"
puts "🔗 Root redirect: #{config["root"] ? "Yes" : "No"}"

