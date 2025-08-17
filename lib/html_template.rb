# frozen_string_literal: true

class HtmlTemplate
  def self.render(root_redirect:, categories:, total_count:)
    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>jsua.co Short URLs</title>
          #{styles}
      </head>
      <body>
          <div class="container">
              <h1>jsua.co Short URLs</h1>
              <p class="subtitle">Click to visit or copy any short URL</p>
              
              #{root_section(root_redirect)}
              #{category_sections(categories)}
              
              <div class="stats">
                  <p><strong>Total Short URLs:</strong> #{total_count}</p>
                  #{statistics(categories, root_redirect)}
              </div>
          </div>
          
          #{javascript}
      </body>
      </html>
    HTML
  end

  def self.styles
    <<~CSS
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
    CSS
  end

  def self.javascript
    <<~JS
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
    JS
  end

  def self.root_section(root_redirect)
    return "" unless root_redirect

    <<~HTML
      <div class="section">
          <h2>Root Domain</h2>
          <div class="links-grid">
              <div class="link-card root-redirect">
                  <div class="link-info">
                      <a href="https://jsua.co/" class="link-url" target="_blank">jsua.co/</a>
                      <div class="link-desc">Redirects to #{html_escape(root_redirect["url"])}</div>
                  </div>
                  <button class="copy-btn" onclick="copyToClipboard('https://jsua.co/', this)">Copy</button>
              </div>
          </div>
      </div>
    HTML
  end

  def self.category_sections(categories)
    categories.map do |category_title, redirects|
      next if redirects.empty?

      links = redirects.map { |redirect| link_card(redirect) }.join("\n")

      <<~HTML
        <div class="section">
            <h2>#{html_escape(category_title)}</h2>
            <div class="links-grid">
                #{links}
            </div>
        </div>
      HTML
    end.compact.join("\n")
  end

  def self.link_card(redirect)
    path = redirect["path"]
    description = redirect["description"] || redirect["url"]
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

  def self.statistics(categories, root_redirect)
    stats = []
    stats << "<p><strong>Root redirect:</strong> Yes</p>" if root_redirect

    categories.each do |category_title, redirects|
      next if redirects.empty?
      stats << "<p><strong>#{html_escape(category_title)}:</strong> #{redirects.length} links</p>"
    end

    stats.join("\n")
  end

  def self.html_escape(text)
    text.to_s
      .gsub("&", "&amp;")
      .gsub("<", "&lt;")
      .gsub(">", "&gt;")
      .gsub('"', "&quot;")
      .gsub("'", "&#39;")
  end
end
