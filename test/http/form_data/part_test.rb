# frozen_string_literal: true

require "test_helper"

class PartTest < Minitest::Test
  cover "HTTP::FormData::Part*"
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

  # --- Kill mutations for Part#initialize ---

  # Kill: @io = StringIO.new(body.to_s) replaced with @io = StringIO.new(body) etc
  # Verify that body is converted via to_s
  def test_initialize_converts_body_to_string
    part = HTTP::FormData::Part.new(42)

    assert_equal "42", part.to_s
  end

  def test_initialize_with_symbol_body
    part = HTTP::FormData::Part.new(:hello)

    assert_equal "hello", part.to_s
  end

  # Kill: @content_type = content_type replaced with @content_type = nil
  def test_content_type_stores_exact_value
    part = HTTP::FormData::Part.new("body", content_type: "text/plain")

    assert_equal "text/plain", part.content_type
    refute_nil part.content_type
  end

  # Kill: @filename = filename replaced with @filename = nil
  def test_filename_stores_exact_value
    part = HTTP::FormData::Part.new("body", filename: "test.txt")

    assert_equal "test.txt", part.filename
    refute_nil part.filename
  end

  # Kill: StringIO.new(body.to_s) replaced with StringIO.new(nil.to_s) or other
  def test_initialize_preserves_body_content
    part = HTTP::FormData::Part.new("specific content")

    assert_equal "specific content", part.read
    assert_equal 16, part.size
  end

  # Kill: Readable#read with length
  def test_read_with_length
    part = HTTP::FormData::Part.new("hello world")

    assert_equal "hello", part.read(5)
    assert_equal " worl", part.read(5)
    assert_equal "d", part.read(5)
    assert_nil part.read(5)
  end

  def test_read_with_nil_length
    part = HTTP::FormData::Part.new("hello")

    assert_equal "hello", part.read(nil)
  end

  def test_read_with_outbuf
    part = HTTP::FormData::Part.new("hello")
    buf = +""
    result = part.read(3, buf)

    assert_equal "hel", result
    assert_equal "hel", buf
  end
end
