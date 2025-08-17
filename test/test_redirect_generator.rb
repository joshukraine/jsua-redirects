# frozen_string_literal: true

require_relative "test_helper"
require_relative "../lib/redirect_generator"

class TestRedirectGenerator < Minitest::Test
  def setup
    @temp_dir = Dir.mktmpdir
    @config_file = File.join(@temp_dir, "test_redirects.yaml")
    @output_file = File.join(@temp_dir, "_redirects")
  end

  def teardown
    FileUtils.remove_entry(@temp_dir)
  end

  def test_raises_error_when_config_file_missing
    generator = RedirectGenerator.new(
      config_file: "nonexistent.yaml",
      output_file: @output_file
    )

    assert_raises(RuntimeError) do
      generator.generate
    end
  end

  def test_generates_empty_redirects_file_with_minimal_config
    write_yaml(@config_file, {})

    generator = RedirectGenerator.new(
      config_file: @config_file,
      output_file: @output_file
    )

    result = generator.generate

    assert File.exist?(@output_file)
    assert_equal 0, result[:total_redirects]
    assert_equal false, result[:has_root]

    content = File.read(@output_file)
    assert_includes content, "# jsua.co URL Redirects"
    assert_includes content, "# WARNING: This file is auto-generated. DO NOT EDIT DIRECTLY!"
    assert_includes content, "# vim: set filetype=apache:"
  end

  def test_generates_root_redirect
    config = {
      "root" => {
        "url" => "https://example.com/",
        "status" => 301
      }
    }
    write_yaml(@config_file, config)

    generator = RedirectGenerator.new(
      config_file: @config_file,
      output_file: @output_file
    )

    result = generator.generate

    assert_equal true, result[:has_root]

    content = File.read(@output_file)
    assert_includes content, "# Root domain redirect"
    assert_includes content, "/ https://example.com/ 301"
  end

  def test_generates_simple_redirect
    config = {
      "redirects" => [
        {
          "path" => "test",
          "url" => "https://test.com",
          "status" => 301
        }
      ]
    }
    write_yaml(@config_file, config)

    generator = RedirectGenerator.new(
      config_file: @config_file,
      output_file: @output_file
    )

    result = generator.generate

    assert_equal 1, result[:total_redirects]

    content = File.read(@output_file)
    # Check for trailing slash redirect
    assert_includes content, "/test/ /test 301"
    # Check for actual redirect
    assert_includes content, "/test https://test.com 301"
  end

  def test_defaults_to_301_status
    config = {
      "redirects" => [
        {
          "path" => "test",
          "url" => "https://test.com"
          # No status specified
        }
      ]
    }
    write_yaml(@config_file, config)

    generator = RedirectGenerator.new(
      config_file: @config_file,
      output_file: @output_file
    )

    generator.generate

    content = File.read(@output_file)
    assert_includes content, "/test https://test.com 301"
  end

  def test_categorizes_redirects_correctly
    config = {
      "redirects" => [
        {
          "path" => "personal1",
          "url" => "https://personal1.com",
          "category" => "personal"
        },
        {
          "path" => "dev1",
          "url" => "https://dev1.com",
          "category" => "developer"
        },
        {
          "path" => "ministry1",
          "url" => "https://ministry1.com",
          "category" => "ministry"
        },
        {
          "path" => "third1",
          "url" => "https://third1.com",
          "category" => "third_party"
        }
      ]
    }
    write_yaml(@config_file, config)

    generator = RedirectGenerator.new(
      config_file: @config_file,
      output_file: @output_file
    )

    generator.generate

    content = File.read(@output_file)

    # Check categories appear in order
    personal_pos = content.index("# Personal Links")
    developer_pos = content.index("# Developer Links")
    ministry_pos = content.index("# Ministry Links")
    third_party_pos = content.index("# Third Party Links")

    assert personal_pos < developer_pos
    assert developer_pos < ministry_pos
    assert ministry_pos < third_party_pos

    # Check redirects are under correct categories
    assert_match(/# Personal Links.*\/personal1 https:\/\/personal1.com 301/m, content)
    assert_match(/# Developer Links.*\/dev1 https:\/\/dev1.com 301/m, content)
    assert_match(/# Ministry Links.*\/ministry1 https:\/\/ministry1.com 301/m, content)
    assert_match(/# Third Party Links.*\/third1 https:\/\/third1.com 301/m, content)
  end

  def test_defaults_to_personal_category
    config = {
      "redirects" => [
        {
          "path" => "test",
          "url" => "https://test.com"
          # No category specified
        }
      ]
    }
    write_yaml(@config_file, config)

    generator = RedirectGenerator.new(
      config_file: @config_file,
      output_file: @output_file
    )

    generator.generate

    content = File.read(@output_file)
    assert_match(/# Personal Links.*\/test https:\/\/test.com 301/m, content)
  end

  def test_handles_empty_categories
    config = {
      "redirects" => [
        {
          "path" => "dev1",
          "url" => "https://dev1.com",
          "category" => "developer"
        }
        # No personal, ministry, or third_party redirects
      ]
    }
    write_yaml(@config_file, config)

    generator = RedirectGenerator.new(
      config_file: @config_file,
      output_file: @output_file
    )

    generator.generate

    content = File.read(@output_file)

    # Should only have Developer Links section
    assert_includes content, "# Developer Links"
    refute_includes content, "# Personal Links"
    refute_includes content, "# Ministry Links"
    refute_includes content, "# Third Party Links"
  end

  private

  def write_yaml(file, content)
    File.write(file, content.to_yaml)
  end
end
