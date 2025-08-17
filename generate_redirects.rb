#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/redirect_generator"

begin
  generator = RedirectGenerator.new
  result = generator.generate

  puts "✅ Generated _redirects file successfully!"
  puts "📝 Total redirects: #{result[:total_redirects]}"
  puts "🔗 Root redirect: #{result[:has_root] ? "Yes" : "No"}"
rescue => e
  puts e.message
  exit 1
end
