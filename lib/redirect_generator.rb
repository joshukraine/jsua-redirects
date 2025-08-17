# frozen_string_literal: true

require "yaml"

class RedirectGenerator
  attr_reader :config_file, :output_file, :html_output_file

  def initialize(config_file: "redirects.yaml", output_file: "_redirects", html_output_file: "links.html")
    @config_file = config_file
    @output_file = output_file
    @html_output_file = html_output_file
  end

  def generate
    unless File.exist?(config_file)
      raise "Error: #{config_file} not found!"
    end

    config = YAML.safe_load_file(
      config_file,
      permitted_classes: [Hash, Array, String, Integer, Float, NilClass, TrueClass, FalseClass]
    )
    write_redirects(config)
    write_html_page(config)

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
    file.puts "# Special rule to serve HTML landing page"
    file.puts "/links /links.html 200"
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

  def write_html_page(config)
    File.open(html_output_file, "w") do |file|
      file.puts generate_html_content(config)
    end
  end

  def generate_html_content(config)
    root_redirect = config["root"]
    redirects_by_category = config["redirects"] || {}
    total_redirects = count_total_redirects(redirects_by_category)
    total_with_root = total_redirects + (root_redirect ? 1 : 0)

    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>jsua.co Short URLs</title>
          <style>
              body {
                  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                  color: white;
                  margin: 0;
                  padding: 2rem;
                  min-height: 100vh;
              }
              .container {
                  max-width: 1000px;
                  margin: 0 auto;
                  background: rgba(255, 255, 255, 0.1);
                  border-radius: 12px;
                  padding: 2rem;
                  backdrop-filter: blur(10px);
              }
              h1 {
                  text-align: center;
                  margin-bottom: 0.5rem;
                  font-size: 2.5rem;
              }
              .subtitle {
                  text-align: center;
                  margin-bottom: 2rem;
                  opacity: 0.9;
                  font-size: 1.1rem;
              }
              .section {
                  margin: 2rem 0;
              }
              .section h2 {
                  font-size: 1.5rem;
                  margin-bottom: 1rem;
                  border-bottom: 2px solid rgba(255, 255, 255, 0.3);
                  padding-bottom: 0.5rem;
              }
              .links-grid {
                  display: grid;
                  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                  gap: 12px;
                  margin-bottom: 1rem;
              }
              .link-card {
                  display: flex;
                  align-items: center;
                  justify-content: space-between;
                  background: rgba(255, 255, 255, 0.15);
                  padding: 12px 16px;
                  border-radius: 8px;
                  border: 1px solid rgba(255, 255, 255, 0.2);
                  transition: all 0.3s ease;
              }
              .link-card:hover {
                  background: rgba(255, 255, 255, 0.25);
                  border-color: rgba(255, 255, 255, 0.4);
                  transform: translateY(-2px);
              }
              .link-info {
                  flex: 1;
                  min-width: 0;
              }
              .link-url {
                  display: block;
                  color: white;
                  text-decoration: none;
                  font-weight: 600;
                  font-size: 0.95rem;
                  margin-bottom: 0.25rem;
                  overflow: hidden;
                  text-overflow: ellipsis;
                  white-space: nowrap;
              }
              .link-url:hover {
                  text-decoration: underline;
              }
              .link-desc {
                  font-size: 0.8rem;
                  opacity: 0.8;
                  overflow: hidden;
                  text-overflow: ellipsis;
                  white-space: nowrap;
              }
              .copy-btn {
                  background: rgba(255, 255, 255, 0.2);
                  border: 1px solid rgba(255, 255, 255, 0.3);
                  color: white;
                  padding: 6px 12px;
                  border-radius: 6px;
                  cursor: pointer;
                  font-size: 0.85rem;
                  transition: all 0.3s ease;
                  white-space: nowrap;
                  margin-left: 12px;
              }
              .copy-btn:hover {
                  background: rgba(255, 255, 255, 0.3);
                  border-color: rgba(255, 255, 255, 0.5);
              }
              .copy-btn.copied {
                  background: rgba(76, 175, 80, 0.3);
                  border-color: rgba(76, 175, 80, 0.5);
              }
              .stats {
                  text-align: center;
                  margin-top: 2rem;
                  padding: 1rem;
                  background: rgba(255, 255, 255, 0.1);
                  border-radius: 8px;
              }
              .root-redirect {
                  background: rgba(255, 255, 255, 0.2);
                  border: 2px solid rgba(255, 255, 255, 0.3);
              }
              @media (max-width: 640px) {
                  .links-grid {
                      grid-template-columns: 1fr;
                  }
                  h1 {
                      font-size: 2rem;
                  }
                  .container {
                      padding: 1.5rem;
                  }
                  body {
                      padding: 1rem;
                  }
              }
          </style>
      </head>
      <body>
          <div class="container">
              <h1>jsua.co Short URLs</h1>
              <p class="subtitle">Click to visit or copy any short URL</p>
              
              #{generate_root_section(root_redirect)}
              #{generate_category_sections(redirects_by_category)}
              
              <div class="stats">
                  <p><strong>Total Short URLs:</strong> #{total_with_root}</p>
                  #{generate_category_stats(redirects_by_category, root_redirect)}
              </div>
          </div>
          
          <script>
              function copyToClipboard(text, button) {
                  if (navigator.clipboard && navigator.clipboard.writeText) {
                      navigator.clipboard.writeText(text).then(() => {
                          showCopiedFeedback(button);
                      }).catch(() => {
                          fallbackCopy(text, button);
                      });
                  } else {
                      fallbackCopy(text, button);
                  }
              }
              
              function fallbackCopy(text, button) {
                  const textArea = document.createElement('textarea');
                  textArea.value = text;
                  textArea.style.position = 'fixed';
                  textArea.style.opacity = '0';
                  document.body.appendChild(textArea);
                  textArea.select();
                  try {
                      document.execCommand('copy');
                      showCopiedFeedback(button);
                  } catch (err) {
                      console.error('Failed to copy:', err);
                  }
                  document.body.removeChild(textArea);
              }
              
              function showCopiedFeedback(button) {
                  const originalText = button.textContent;
                  button.textContent = 'Copied!';
                  button.classList.add('copied');
                  setTimeout(() => {
                      button.textContent = originalText;
                      button.classList.remove('copied');
                  }, 2000);
              }
          </script>
      </body>
      </html>
    HTML
  end

  def generate_root_section(root_redirect)
    return "" unless root_redirect

    <<~HTML
      <div class="section">
          <h2>Root Domain</h2>
          <div class="links-grid">
              <div class="link-card root-redirect">
                  <div class="link-info">
                      <a href="https://jsua.co/" class="link-url" target="_blank">jsua.co/</a>
                      <div class="link-desc">Redirects to #{root_redirect["url"]}</div>
                  </div>
                  <button class="copy-btn" onclick="copyToClipboard('https://jsua.co/', this)">Copy</button>
              </div>
          </div>
      </div>
    HTML
  end

  def generate_category_sections(redirects_by_category)
    sections = []
    redirects_by_category.each do |category_key, category_redirects|
      next unless category_redirects&.any?

      category_title = format_category_title(category_key).sub(" Links", "")
      sections << generate_category_section(category_title, category_redirects)
    end
    sections.join("\n")
  end

  def generate_category_section(category_title, redirects)
    links_html = redirects.map { |redirect| generate_link_card(redirect) }.join("\n")

    <<~HTML
      <div class="section">
          <h2>#{category_title}</h2>
          <div class="links-grid">
              #{links_html}
          </div>
      </div>
    HTML
  end

  def generate_link_card(redirect)
    path = redirect["path"]
    url = redirect["url"]
    description = redirect["description"] || url
    full_url = "https://jsua.co/#{path}"

    <<~HTML
      <div class="link-card">
          <div class="link-info">
              <a href="#{full_url}" class="link-url" target="_blank">jsua.co/#{html_escape(path)}</a>
              <div class="link-desc" title="#{html_escape(description)}">#{html_escape(description)}</div>
          </div>
          <button class="copy-btn" onclick="copyToClipboard('#{full_url}', this)">Copy</button>
      </div>
    HTML
  end

  def generate_category_stats(redirects_by_category, root_redirect)
    stats = []
    stats << "<p><strong>Root redirect:</strong> Yes</p>" if root_redirect

    redirects_by_category.each do |category_key, category_redirects|
      next unless category_redirects&.any?
      category_title = format_category_title(category_key).sub(" Links", "")
      stats << "<p><strong>#{category_title}:</strong> #{category_redirects.length} links</p>"
    end

    stats.join("\n")
  end

  def html_escape(text)
    text.to_s
      .gsub("&", "&amp;")
      .gsub("<", "&lt;")
      .gsub(">", "&gt;")
      .gsub('"', "&quot;")
      .gsub("'", "&#39;")
  end
end
