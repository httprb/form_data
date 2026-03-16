# frozen_string_literal: true

require "test_helper"

class FormDataTest < Minitest::Test
  cover "HTTP::FormData*"
  include FixturesHelper

  def test_create_returns_urlencoded_when_no_files
    result = HTTP::FormData.create({ foo: :bar })

    assert_instance_of HTTP::FormData::Urlencoded, result
  end

  def test_create_returns_multipart_when_file_param
    file = HTTP::FormData::File.new(fixture("the-http-gem.info").to_s)
    result = HTTP::FormData.create({ foo: :bar, baz: file })

    assert_instance_of HTTP::FormData::Multipart, result
  end

  def test_create_returns_multipart_when_file_in_array_param
    file = HTTP::FormData::File.new(fixture("the-http-gem.info").to_s)
    result = HTTP::FormData.create({ foo: :bar, baz: [file] })

    assert_instance_of HTTP::FormData::Multipart, result
  end

  def test_ensure_data_with_hash
    assert_equal({ foo: :bar }, HTTP::FormData.ensure_data({ foo: :bar }))
  end

  def test_ensure_data_with_array
    data = [%i[foo bar], %i[foo baz]]

    assert_equal data, HTTP::FormData.ensure_data(data)
  end

  def test_ensure_data_with_enumerator
    data = Enumerator.new { |y| y << %i[foo bar] }

    assert_instance_of Enumerator, HTTP::FormData.ensure_data(data)
  end

  def test_ensure_data_with_to_h
    obj = Object.new
    def obj.to_h = { foo: :bar }

    assert_equal({ foo: :bar }, HTTP::FormData.ensure_data(obj))
  end

  def test_ensure_data_with_nil
    assert_equal [], HTTP::FormData.ensure_data(nil)
  end

  def test_ensure_data_with_invalid_input
    error = assert_raises(HTTP::FormData::Error) { HTTP::FormData.ensure_data(42) }

    assert_includes error.message, "42"
    assert_includes error.message, "is neither Enumerable nor responds to :to_h"
  end

  def test_ensure_hash_with_hash
    assert_equal({ foo: :bar }, HTTP::FormData.ensure_hash({ foo: :bar }))
  end

  def test_ensure_hash_with_to_h
    obj = Object.new
    def obj.to_h = { foo: :bar }

    assert_equal({ foo: :bar }, HTTP::FormData.ensure_hash(obj))
  end

  def test_ensure_hash_with_nil
    assert_equal({}, HTTP::FormData.ensure_hash(nil))
  end

  def test_ensure_hash_with_invalid_input
    error = assert_raises(HTTP::FormData::Error) { HTTP::FormData.ensure_hash(42) }

    assert_includes error.message, "42"
    assert_includes error.message, "is neither Hash nor responds to :to_h"
  end

  # --- Kill mutations for ensure_hash ---

  # Kill: replacing obj.nil? with false/nil/self.nil?
  # Verify that nil input specifically returns empty hash (not nil, not false)
  def test_ensure_hash_nil_returns_empty_hash_not_nil
    result = HTTP::FormData.ensure_hash(nil)

    assert_instance_of Hash, result
    assert_empty result
    refute_nil result
  end

  # Kill: replacing obj.is_a?(Hash) with obj.instance_of?(Hash)
  # A subclass of Hash should still be recognized as a Hash and returned as-is
  def test_ensure_hash_with_hash_subclass
    subclass = Class.new(Hash)
    obj = subclass.new
    obj[:foo] = :bar
    result = HTTP::FormData.ensure_hash(obj)

    assert_same obj, result
  end

  # Kill: replacing obj.is_a?(Hash) with nil/false/self.is_a?(Hash)
  # Verify that a Hash is returned as-is (same object)
  def test_ensure_hash_returns_same_hash_object
    input = { foo: :bar }
    result = HTTP::FormData.ensure_hash(input)

    assert_same input, result
  end

  # Kill: replacing obj.respond_to?(:to_h) with nil/false
  # Verify that to_h object that is NOT a Hash goes through to_h path
  def test_ensure_hash_to_h_object_is_not_hash
    obj = Object.new
    def obj.to_h = { converted: true }

    result = HTTP::FormData.ensure_hash(obj)

    assert_instance_of Hash, result
    assert_equal({ converted: true }, result)
  end

  # Kill: false is not nil? but would be treated differently
  def test_ensure_hash_with_false_raises
    assert_raises(HTTP::FormData::Error) { HTTP::FormData.ensure_hash(false) }
  end

  # Kill: error message mutations — obj.inspect vs obj vs nil vs self.inspect vs no message
  def test_ensure_hash_error_message_contains_inspect
    obj = Object.new
    def obj.inspect = "HASH_INSPECT"
    def obj.to_s = "HASH_TO_S"

    error = assert_raises(HTTP::FormData::Error) { HTTP::FormData.ensure_hash(obj) }

    assert_includes error.message, "HASH_INSPECT"
  end

  # --- Kill mutations for ensure_data ---

  # Kill: replacing obj.nil? with false/nil/self.nil?
  def test_ensure_data_nil_returns_empty_array_not_nil
    result = HTTP::FormData.ensure_data(nil)

    assert_instance_of Array, result
    assert_empty result
    refute_nil result
  end

  # Kill: replacing obj.is_a?(Enumerable) with obj.instance_of?(Enumerable)
  # Array is an Enumerable but not instance_of Enumerable
  def test_ensure_data_with_array_returns_same_object
    input = [%i[foo bar]]
    result = HTTP::FormData.ensure_data(input)

    assert_same input, result
  end

  # Kill: replacing obj.is_a?(Enumerable) with nil/false/self.is_a?(Enumerable)
  def test_ensure_data_with_hash_returns_same_hash
    input = { foo: :bar }
    result = HTTP::FormData.ensure_data(input)

    assert_same input, result
  end

  # Kill: ensure_data with to_h fallback (non-Enumerable, responds to to_h)
  def test_ensure_data_to_h_object_not_enumerable
    obj = Object.new
    def obj.to_h = { converted: true }

    result = HTTP::FormData.ensure_data(obj)

    assert_instance_of Hash, result
    assert_equal({ converted: true }, result)
  end

  def test_ensure_data_with_false_raises
    assert_raises(HTTP::FormData::Error) { HTTP::FormData.ensure_data(false) }
  end

  # Kill: error message mutations — obj.inspect vs obj vs nil vs self.inspect vs no message
  def test_ensure_data_error_message_contains_inspect
    obj = Object.new
    def obj.inspect = "CUSTOM_INSPECT"
    def obj.to_s = "CUSTOM_TO_S"

    error = assert_raises(HTTP::FormData::Error) { HTTP::FormData.ensure_data(obj) }

    assert_includes error.message, "CUSTOM_INSPECT"
    refute_includes error.message, "CUSTOM_TO_S"
  end

  # --- Kill mutations for create ---

  # Kill: replacing data = ensure_data(data) with data = data
  # Verify create works with nil data (ensure_data converts nil to [])
  def test_create_with_nil_data
    result = HTTP::FormData.create(nil)

    assert_instance_of HTTP::FormData::Urlencoded, result
    assert_equal "", result.to_s
  end

  # Kill: replacing Multipart.new(data) with Multipart.new(nil)
  # Verify that multipart data flows through correctly
  def test_create_multipart_has_correct_content
    file = HTTP::FormData::File.new(StringIO.new("file content"))
    result = HTTP::FormData.create({ name: file })

    assert_instance_of HTTP::FormData::Multipart, result
    assert_includes result.to_s, "file content"
  end

  # Kill: replacing Urlencoded.new(data, encoder:) with self.new(data, encoder:)
  # Verify urlencoded has correct content (not a FormData module instance)
  def test_create_urlencoded_has_correct_content
    result = HTTP::FormData.create({ foo: "bar" })

    assert_instance_of HTTP::FormData::Urlencoded, result
    assert_equal "foo=bar", result.to_s
  end

  # Kill: replacing encoder: encoder with encoder: nil
  # Verify that custom encoder is passed through create
  def test_create_passes_encoder_to_urlencoded
    custom_encoder = proc { |data| data.map { |k, v| "#{k}:#{v}" }.join(",") }
    result = HTTP::FormData.create({ foo: "bar" }, encoder: custom_encoder)

    assert_instance_of HTTP::FormData::Urlencoded, result
    assert_equal "foo:bar", result.to_s
  end

  # Kill: replacing data = ensure_data data with data = data
  # If ensure_data is not called, a to_h object won't be converted
  def test_create_with_to_h_object
    obj = Object.new
    def obj.to_h = { foo: "bar" }

    result = HTTP::FormData.create(obj)

    assert_instance_of HTTP::FormData::Urlencoded, result
    assert_equal "foo=bar", result.to_s
  end

  # --- Kill mutations for multipart? ---

  # Kill: replacing v.is_a?(FormData::Part) with nil/false
  # Non-Part values should NOT make it multipart
  def test_create_with_string_value_is_not_multipart
    result = HTTP::FormData.create({ foo: "bar", baz: "qux" })

    assert_instance_of HTTP::FormData::Urlencoded, result
  end

  # Kill: replacing v.respond_to?(:to_ary) with nil/false
  # Array without Parts should not be multipart
  def test_create_with_array_of_strings_is_not_multipart
    result = HTTP::FormData.create({ foo: %w[bar baz] })

    assert_instance_of HTTP::FormData::Urlencoded, result
  end

  # Kill: next true if v.is_a?(FormData::Part) — direct Part value
  def test_create_with_part_value_is_multipart
    part = HTTP::FormData::Part.new("hello", content_type: "text/plain")
    result = HTTP::FormData.create({ foo: part })

    assert_instance_of HTTP::FormData::Multipart, result
  end

  # Kill: v.to_ary.any?(FormData::Part)
  def test_create_with_array_containing_part_is_multipart
    part = HTTP::FormData::Part.new("hello", content_type: "text/plain")
    result = HTTP::FormData.create({ foo: [part] })

    assert_instance_of HTTP::FormData::Multipart, result
  end

  # Kill: replacing v.respond_to?(:to_ary) && v.to_ary.any?(FormData::Part)
  # Object responding to to_ary containing a Part
  def test_create_with_to_ary_containing_part_is_multipart
    part = HTTP::FormData::Part.new("hello")
    obj = Object.new
    obj.define_singleton_method(:to_ary) { [part] }
    result = HTTP::FormData.create({ foo: obj })

    assert_instance_of HTTP::FormData::Multipart, result
  end

  # Kill: ensure empty array doesn't trigger multipart
  def test_create_with_empty_array_value_is_not_multipart
    result = HTTP::FormData.create({ foo: [] })

    assert_instance_of HTTP::FormData::Urlencoded, result
  end

  # Kill: Multipart.new(data) vs Multipart.new(nil) — verify data actually appears
  def test_create_multipart_preserves_all_params
    file = HTTP::FormData::File.new(StringIO.new("content"))
    result = HTTP::FormData.create({ user: "ixti", file: file })
    body = result.to_s

    assert_includes body, "ixti"
    assert_includes body, "content"
    assert_includes body, "user"
    assert_includes body, "file"
  end
end
