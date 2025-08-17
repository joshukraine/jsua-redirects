# frozen_string_literal: true

require "yaml"

class RedirectGenerator
  attr_reader :config_file, :output_file

  def initialize(config_file: "redirects.yaml", output_file: "_redirects")
    @config_file = config_file
    @output_file = output_file
  end

  def generate
    unless File.exist?(config_file)
      raise "Error: #{config_file} not found!"
    end

    config = YAML.load_file(config_file)
    write_redirects(config)

    {
      total_redirects: config["redirects"]&.length || 0,
      has_root: !config["root"].nil?
    }
  end

  private

  def write_redirects(config)
    File.open(output_file, "w") do |file|
      write_header(file)
      write_root_redirect(file, config["root"]) if config["root"]

      redirects = config["redirects"] || []
      if redirects.any?
        write_trailing_slash_redirects(file, redirects)
        write_categorized_redirects(file, redirects)
      end

      write_footer(file)
    end
  end

  def write_header(file)
    file.puts "# jsua.co URL Redirects"
    file.puts "# WARNING: This file is auto-generated. DO NOT EDIT DIRECTLY!"
    file.puts "# To modify redirects, edit redirects.yaml and run: ruby generate_redirects.rb"
    file.puts "#"
    file.puts "# Format: /path https://destination-url status-code"
    file.puts
  end

  def write_root_redirect(file, root)
    file.puts "# Root domain redirect"
    status = root["status"] || 301
    file.puts "/ #{root["url"]} #{status}"
    file.puts
  end

  def write_trailing_slash_redirects(file, redirects)
    file.puts "# Trailing slash redirects (handle URLs with trailing slashes)"
    redirects.each do |redirect|
      path = redirect["path"]
      file.puts "/#{path}/ /#{path} 301"
    end
    file.puts
  end

  def write_categorized_redirects(file, redirects)
    categories = {
      "personal" => "Personal Links",
      "developer" => "Developer Links",
      "ministry" => "Ministry Links",
      "third_party" => "Third Party Links"
    }

    grouped_redirects = group_by_category(redirects)

    categories.each do |category_key, category_title|
      write_category(file, category_title, grouped_redirects[category_key])
    end
  end

  def group_by_category(redirects)
    grouped = Hash.new { |h, k| h[k] = [] }

    redirects.each do |redirect|
      category = redirect["category"] || "personal"
      grouped[category] << redirect
    end

    grouped
  end

  def write_category(file, category_title, category_redirects)
    return unless category_redirects&.any?

    file.puts "# #{category_title}"
    category_redirects.each do |redirect|
      path = redirect["path"]
      url = redirect["url"]
      status = redirect["status"] || 301
      file.puts "/#{path} #{url} #{status}"
    end
    file.puts
  end

  def write_footer(file)
    file.puts
    file.puts "# vim: set filetype=apache" + ":"
    file.puts
  end
end
