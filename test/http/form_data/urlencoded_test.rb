# frozen_string_literal: true

require "test_helper"

class UrlencodedTest < Minitest::Test
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
end
