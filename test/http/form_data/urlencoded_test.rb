# frozen_string_literal: true

require "test_helper"

class UrlencodedTest < Minitest::Test
  cover "HTTP::FormData::Urlencoded*"
  def test_raises_error_for_non_enumerable_input
    assert_raises(HTTP::FormData::Error) { HTTP::FormData::Urlencoded.new(42) }
  end

  def test_raises_argument_error_for_non_hash_top_level_in_encoder
    assert_raises(ArgumentError) { HTTP::FormData::Urlencoded.encoder.call(42) }
  end

  def test_supports_enumerables_of_pairs
    form_data = HTTP::FormData::Urlencoded.new([%w[foo bar], ["foo", %w[baz moo]]])

    assert_equal "foo=bar&foo[]=baz&foo[]=moo", form_data.to_s
  end

  def test_content_type
    form_data = HTTP::FormData::Urlencoded.new({ "foo[bar]" => "test" })

    assert_equal "application/x-www-form-urlencoded", form_data.content_type
  end

  def test_content_length
    form_data = HTTP::FormData::Urlencoded.new({ "foo[bar]" => "test" })

    assert_equal form_data.to_s.bytesize, form_data.content_length
  end

  def test_content_length_with_unicode
    form_data = HTTP::FormData::Urlencoded.new({ "foo[bar]" => "тест" })

    assert_equal form_data.to_s.bytesize, form_data.content_length
  end

  def test_to_s
    form_data = HTTP::FormData::Urlencoded.new({ "foo[bar]" => "test" })

    assert_equal "foo%5Bbar%5D=test", form_data.to_s
  end

  def test_to_s_with_unicode
    form_data = HTTP::FormData::Urlencoded.new({ "foo[bar]" => "тест" })

    assert_equal "foo%5Bbar%5D=%D1%82%D0%B5%D1%81%D1%82", form_data.to_s
  end

  def test_to_s_with_nested_hashes
    form_data = HTTP::FormData::Urlencoded.new({ "foo" => { "bar" => "test" } })

    assert_equal "foo[bar]=test", form_data.to_s
  end

  def test_to_s_with_nil_value
    form_data = HTTP::FormData::Urlencoded.new({ "foo" => nil })

    assert_equal "foo", form_data.to_s
  end

  def test_to_s_rewinds_content
    form_data = HTTP::FormData::Urlencoded.new({ "foo[bar]" => "test" })
    content = form_data.read

    assert_equal content, form_data.to_s
    assert_equal content, form_data.read
  end

  def test_size
    form_data = HTTP::FormData::Urlencoded.new({ "foo[bar]" => "test" })

    assert_equal form_data.to_s.bytesize, form_data.size
  end

  def test_read
    form_data = HTTP::FormData::Urlencoded.new({ "foo[bar]" => "test" })

    assert_equal form_data.to_s, form_data.read
  end

  def test_rewind
    form_data = HTTP::FormData::Urlencoded.new({ "foo[bar]" => "test" })
    form_data.read
    form_data.rewind

    assert_equal form_data.to_s, form_data.read
  end

  def test_custom_class_level_encoder
    original_encoder = HTTP::FormData::Urlencoded.encoder
    HTTP::FormData::Urlencoded.encoder = JSON.method(:dump)
    form_data = HTTP::FormData::Urlencoded.new({ "foo[bar]" => "test" })

    assert_equal '{"foo[bar]":"test"}', form_data.to_s
  ensure
    HTTP::FormData::Urlencoded.encoder = original_encoder
  end

  def test_encoder_rejects_non_callable
    assert_raises(ArgumentError) { HTTP::FormData::Urlencoded.encoder = "not callable" }
  end

  def test_custom_instance_level_encoder
    encoder = proc { |data| JSON.dump(data) }
    form_data = HTTP::FormData::Urlencoded.new({ "foo[bar]" => "test" }, encoder: encoder)

    assert_equal '{"foo[bar]":"test"}', form_data.to_s
  end

  # --- Kill mutations for Urlencoded.encoder ---

  # Kill: @encoder ||= DefaultEncoder.method(:encode) replaced with other
  # Verify the default encoder is callable and produces correct output
  def test_default_encoder_returns_callable
    encoder = HTTP::FormData::Urlencoded.encoder

    assert_respond_to encoder, :call
  end

  def test_default_encoder_encodes_correctly
    result = HTTP::FormData::Urlencoded.encoder.call({ "key" => "value" })

    assert_equal "key=value", result
  end

  # Kill: encoder ||= self.class.encoder replaced with encoder = self.class.encoder
  # Verify that passing nil encoder uses class-level default
  def test_nil_encoder_uses_class_default
    form_data = HTTP::FormData::Urlencoded.new({ foo: "bar" }, encoder: nil)

    assert_equal "foo=bar", form_data.to_s
  end

  # Kill: encoder ||= self.class.encoder — verify custom encoder is used (not replaced by default)
  def test_custom_encoder_is_not_overridden_by_default
    calls = []
    custom = proc { |data|
      calls << data
      "custom"
    }
    form_data = HTTP::FormData::Urlencoded.new({ a: "b" }, encoder: custom)

    assert_equal "custom", form_data.to_s
    refute_empty calls
  end

  # Kill: FormData.ensure_data(data) replaced with data in initialize
  # Verify nil data works (ensure_data converts nil to [])
  def test_initialize_with_nil_data
    form_data = HTTP::FormData::Urlencoded.new(nil)

    assert_equal "", form_data.to_s
  end

  # Kill: Verify ensure_data is called on the data (to_h object should work)
  def test_initialize_with_to_h_object
    obj = Object.new
    def obj.to_h = { x: "y" }

    form_data = HTTP::FormData::Urlencoded.new(obj)

    assert_equal "x=y", form_data.to_s
  end

  # Kill: StringIO.new(encoder.call(...)) replaced with StringIO.new(nil) etc.
  def test_initialize_stores_encoded_content
    form_data = HTTP::FormData::Urlencoded.new({ a: "1", b: "2" })

    assert_equal "a=1&b=2", form_data.to_s
    assert_equal 7, form_data.size
  end

  # Kill: Readable#read with length
  def test_read_with_length
    form_data = HTTP::FormData::Urlencoded.new({ foo: "bar" })

    assert_equal "fo", form_data.read(2)
    assert_equal "o=b", form_data.read(3)
    assert_equal "ar", form_data.read(5)
    assert_nil form_data.read(1)
  end

  def test_read_with_nil_length
    form_data = HTTP::FormData::Urlencoded.new({ foo: "bar" })

    assert_equal "foo=bar", form_data.read(nil)
  end
end
