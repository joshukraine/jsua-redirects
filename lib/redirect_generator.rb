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
      total_redirects: count_total_redirects(config["redirects"]),
      has_root: !config["root"].nil?
    }
  end

  private

  def write_redirects(config)
    File.open(output_file, "w") do |file|
      write_header(file)
      write_root_redirect(file, config["root"]) if config["root"]

      redirects_by_category = config["redirects"] || {}
      if redirects_by_category.any?
        all_redirects = flatten_redirects(redirects_by_category)
        write_trailing_slash_redirects(file, all_redirects)
        write_categorized_redirects(file, redirects_by_category)
      end

      write_footer(file)
    end
  end

  def write_header(file)
    file.puts "# jsua.co URL Redirects"
    file.puts "#"
    file.puts "# WARNING: This file is auto-generated. Do not edit directly!"
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

  def write_categorized_redirects(file, redirects_by_category)
    redirects_by_category.each do |category_key, category_redirects|
      next unless category_redirects&.any?

      category_title = format_category_title(category_key)
      write_category(file, category_title, category_redirects)
    end
  end

  def format_category_title(category_key)
    # Convert category key to display title
    # e.g., "third_party" => "Third Party Links"
    category_key.split("_").map(&:capitalize).join(" ") + " Links"
  end

  def flatten_redirects(redirects_by_category)
    redirects_by_category.values.compact.flatten
  end

  def count_total_redirects(redirects_by_category)
    return 0 unless redirects_by_category

    redirects_by_category.values.compact.sum { |category_redirects| category_redirects&.length || 0 }
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
    file.puts vim_ft_comment
  end

  # Generate vim modeline comment for the _redirects file
  # Broken into parts to prevent Neovim from interpreting this as a modeline
  # when editing this Ruby source file
  def vim_ft_comment
    ["# " + "vim: ", "set ", "filetype", "=", "apache:"].join("")
  end
end
