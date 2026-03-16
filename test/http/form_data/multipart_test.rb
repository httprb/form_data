# frozen_string_literal: true

require "test_helper"

class MultipartTest < Minitest::Test
  include FixturesHelper

  BOUNDARY_PATTERN = /-{21}[a-f0-9]{42}/
  CRLF = "\r\n"

  def setup
    @file = HTTP::FormData::File.new(fixture("the-http-gem.info"))
    @params = { foo: :bar, baz: @file }
    @form_data = HTTP::FormData::Multipart.new(@params)
  end

  def disposition(params)
    params = params.map { |k, v| "#{k}=#{v.inspect}" }.join("; ")
    "Content-Disposition: form-data; #{params}"
  end

  def test_properly_generates_multipart_data
    b = @form_data.boundary
    expected = [
      "--#{b}#{CRLF}",
      "#{disposition 'name' => 'foo'}#{CRLF}",
      "#{CRLF}bar#{CRLF}",
      "--#{b}#{CRLF}",
      "#{disposition 'name' => 'baz', 'filename' => @file.filename}#{CRLF}",
      "Content-Type: #{@file.content_type}#{CRLF}",
      "#{CRLF}#{@file}#{CRLF}",
      "--#{b}--#{CRLF}"
    ].join

    assert_equal expected, @form_data.to_s
  end

  def test_to_s_rewinds_content
    content = @form_data.read

    assert_equal content, @form_data.to_s
    assert_equal content, @form_data.read
  end

  def test_user_defined_boundary
    form_data = HTTP::FormData::Multipart.new(@params, boundary: "my-boundary")
    expected = [
      "--my-boundary#{CRLF}",
      "#{disposition 'name' => 'foo'}#{CRLF}",
      "#{CRLF}bar#{CRLF}",
      "--my-boundary#{CRLF}",
      "#{disposition 'name' => 'baz', 'filename' => @file.filename}#{CRLF}",
      "Content-Type: #{@file.content_type}#{CRLF}",
      "#{CRLF}#{@file}#{CRLF}",
      "--my-boundary--#{CRLF}"
    ].join

    assert_equal expected, form_data.to_s
  end

  def test_part_without_filename
    part = HTTP::FormData::Part.new("s", content_type: "mime/type")
    form_data = HTTP::FormData::Multipart.new({ foo: part })
    b = form_data.content_type[/(#{BOUNDARY_PATTERN})$/o, 1]

    expected = [
      "--#{b}#{CRLF}",
      "#{disposition 'name' => 'foo'}#{CRLF}",
      "Content-Type: #{part.content_type}#{CRLF}",
      "#{CRLF}s#{CRLF}",
      "--#{b}--#{CRLF}"
    ].join

    assert_equal expected, form_data.to_s
  end

  def test_part_without_content_type
    part = HTTP::FormData::Part.new("s")
    form_data = HTTP::FormData::Multipart.new({ foo: part })
    b = form_data.content_type[/(#{BOUNDARY_PATTERN})$/o, 1]

    expected = [
      "--#{b}#{CRLF}",
      "#{disposition 'name' => 'foo'}#{CRLF}",
      "#{CRLF}s#{CRLF}",
      "--#{b}--#{CRLF}"
    ].join

    assert_equal expected, form_data.to_s
  end

  def test_supports_enumerable_of_pairs
    enum = Enumerator.new { |y| y << %i[foo bar] << %i[foo baz] }
    form_data = HTTP::FormData::Multipart.new(enum)
    b = form_data.boundary

    expected = [
      "--#{b}#{CRLF}",
      "#{disposition 'name' => 'foo'}#{CRLF}",
      "#{CRLF}bar#{CRLF}",
      "--#{b}#{CRLF}",
      "#{disposition 'name' => 'foo'}#{CRLF}",
      "#{CRLF}baz#{CRLF}",
      "--#{b}--#{CRLF}"
    ].join

    assert_equal expected, form_data.to_s
  end

  def test_array_of_pairs_with_duplicate_names
    params = [
      ["metadata", %(filename="first.txt")],
      ["file", HTTP::FormData::File.new(StringIO.new("uno"), content_type: "plain/text", filename: "abc")],
      ["metadata", %(filename="second.txt")],
      ["file", HTTP::FormData::File.new(StringIO.new("dos"), content_type: "plain/text", filename: "xyz")],
      ["metadata", %w[question=why question=not]]
    ]
    form_data = HTTP::FormData::Multipart.new(params)
    b = form_data.boundary

    expected = [
      %(--#{b}\r\n),
      %(Content-Disposition: form-data; name="metadata"\r\n),
      %(\r\nfilename="first.txt"\r\n),
      %(--#{b}\r\n),
      %(Content-Disposition: form-data; name="file"; filename="abc"\r\n),
      %(Content-Type: plain/text\r\n),
      %(\r\nuno\r\n),
      %(--#{b}\r\n),
      %(Content-Disposition: form-data; name="metadata"\r\n),
      %(\r\nfilename="second.txt"\r\n),
      %(--#{b}\r\n),
      %(Content-Disposition: form-data; name="file"; filename="xyz"\r\n),
      %(Content-Type: plain/text\r\n),
      %(\r\ndos\r\n),
      %(--#{b}\r\n),
      %(Content-Disposition: form-data; name="metadata"\r\n),
      %(\r\nquestion=why\r\n),
      %(--#{b}\r\n),
      %(Content-Disposition: form-data; name="metadata"\r\n),
      %(\r\nquestion=not\r\n),
      %(--#{b}--\r\n)
    ].join

    assert_equal expected, form_data.to_s
  end

  def test_size_returns_bytesize
    assert_equal @form_data.to_s.bytesize, @form_data.size
  end

  def test_read_returns_multipart_data
    assert_equal @form_data.to_s, @form_data.read
  end

  def test_rewind
    @form_data.read
    @form_data.rewind

    assert_equal @form_data.to_s, @form_data.read
  end

  def test_content_type_matches_pattern
    assert_match(%r{^multipart/form-data; boundary=#{BOUNDARY_PATTERN}$}o, @form_data.content_type)
  end

  def test_content_type_with_user_defined_boundary
    form_data = HTTP::FormData::Multipart.new(@params, boundary: "my-boundary")

    assert_equal "multipart/form-data; boundary=my-boundary", form_data.content_type
  end

  def test_content_length
    assert_equal @form_data.to_s.bytesize, @form_data.content_length
  end

  def test_boundary_matches_pattern
    assert_match(BOUNDARY_PATTERN, @form_data.boundary)
  end

  def test_boundary_with_user_defined_value
    form_data = HTTP::FormData::Multipart.new(@params, boundary: "my-boundary")

    assert_equal "my-boundary", form_data.boundary
  end

  def test_generate_boundary
    assert_match(BOUNDARY_PATTERN, HTTP::FormData::Multipart.generate_boundary)
  end
end
