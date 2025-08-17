# frozen_string_literal: true

require "minitest/autorun"
require "minitest/reporters"
require "tempfile"
require "fileutils"
require "yaml"

# Use the default reporter with colors (shows dots for pass, F for fail)
Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new(
  color: true,
  slow_count: 5,
  detailed_skip: false
)
