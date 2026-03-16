# frozen_string_literal: true

require "test_helper"

class FormDataTest < Minitest::Test
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
    assert_raises(HTTP::FormData::Error) { HTTP::FormData.ensure_data(42) }
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
    assert_raises(HTTP::FormData::Error) { HTTP::FormData.ensure_hash(42) }
  end
end
