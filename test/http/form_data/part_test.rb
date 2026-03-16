# frozen_string_literal: true

require "test_helper"

class PartTest < Minitest::Test
  def test_size_with_string_body
    part = HTTP::FormData::Part.new("привет мир!")

    assert_equal 20, part.size
  end

  def test_to_s_with_string_body
    part = HTTP::FormData::Part.new("привет мир!")

    assert_equal "привет мир!", part.to_s
  end

  def test_to_s_rewinds_content
    part = HTTP::FormData::Part.new("привет мир!")
    part.to_s
    content = part.read

    assert_equal content, part.to_s
    assert_equal content, part.read
  end

  def test_read_with_string_body
    part = HTTP::FormData::Part.new("привет мир!")

    assert_equal "привет мир!", part.read
  end

  def test_rewind
    part = HTTP::FormData::Part.new("привет мир!")
    part.read
    part.rewind

    assert_equal "привет мир!", part.read
  end

  def test_filename_defaults_to_nil
    part = HTTP::FormData::Part.new("")

    assert_nil part.filename
  end

  def test_filename_with_option
    part = HTTP::FormData::Part.new("", filename: "foobar.txt")

    assert_equal "foobar.txt", part.filename
  end

  def test_content_type_defaults_to_nil
    part = HTTP::FormData::Part.new("")

    assert_nil part.content_type
  end

  def test_content_type_with_option
    part = HTTP::FormData::Part.new("", content_type: "application/json")

    assert_equal "application/json", part.content_type
  end
end
