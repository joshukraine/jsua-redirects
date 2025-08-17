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

    # Define categories and their display names
    categories = {
      "personal" => "Personal Links",
      "developer" => "Developer Links",
      "ministry" => "Ministry Links",
      "third_party" => "Third Party Links"
    }

    # Group redirects by category
    grouped_redirects = Hash.new { |h, k| h[k] = [] }

    redirects.each do |redirect|
      category = redirect["category"] || "personal"
      grouped_redirects[category] << redirect
    end

    # Helper method to write redirects for a category
    write_category = lambda do |category_key, category_title, category_redirects|
      if category_redirects.any?
        file.puts "# #{category_title}"
        category_redirects.each do |redirect|
          path = redirect["path"]
          url = redirect["url"]
          status = redirect["status"] || 301
          file.puts "/#{path} #{url} #{status}"
        end
        file.puts
      end
    end

    # Write each category in order
    categories.each do |category_key, category_title|
      write_category.call(category_key, category_title, grouped_redirects[category_key])
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
