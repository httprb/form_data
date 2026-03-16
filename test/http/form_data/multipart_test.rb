# frozen_string_literal: true

require "test_helper"

class MultipartTest < Minitest::Test
  cover "HTTP::FormData::Multipart*"
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

  # --- Kill mutations for Multipart#initialize ---

  # Kill: @boundary = boundary.to_s.freeze replaced with other
  def test_boundary_is_frozen_string
    assert_predicate @form_data.boundary, :frozen?
    assert_instance_of String, @form_data.boundary
  end

  # Kill: boundary.to_s.freeze -> boundary.freeze (without to_s)
  # Kill: boundary.to_s.freeze -> boundary.to_str.freeze
  # Pass a non-string boundary (Symbol) to exercise to_s conversion
  def test_boundary_with_symbol_value
    form_data = HTTP::FormData::Multipart.new({ foo: "bar" }, boundary: :"my-sym-boundary")

    assert_equal "my-sym-boundary", form_data.boundary
    assert_instance_of String, form_data.boundary
  end

  # Kill: CompositeIO.new(...) mutations
  # Verify that reading from multipart returns actual content
  def test_initialize_creates_readable_composite_io
    content = @form_data.read
    @form_data.rewind
    content_again = @form_data.read

    assert_equal content, content_again
    refute_empty content
  end

  # Kill: parts(data) replaced with parts(nil) or other
  def test_initialize_uses_data_for_parts
    form = HTTP::FormData::Multipart.new({ key: "value" }, boundary: "b")
    body = form.to_s

    assert_includes body, "key"
    assert_includes body, "value"
  end

  # --- Kill mutations for Multipart#parts ---

  # Kill: FormData.ensure_data(data) replaced with data
  # Verify that parts works with nil (ensure_data converts to [])
  def test_parts_with_nil_data_via_ensure_data
    form = HTTP::FormData::Multipart.new(nil, boundary: "test-boundary")

    # Should just have the tail, no parts
    assert_equal "--test-boundary--\r\n", form.to_s
  end

  # Kill: Array(values).each mutations
  # Array wrapping of values
  def test_parts_wraps_single_value
    form = HTTP::FormData::Multipart.new({ name: "single" }, boundary: "b")
    body = form.to_s

    assert_includes body, "single"
    # Should appear exactly once
    assert_equal 1, body.scan("single").length
  end

  # --- Kill mutations for Multipart::Param#initialize ---

  # Kill: @name = name.to_s replaced with @name = name
  def test_param_converts_name_to_string
    part = HTTP::FormData::Part.new("val")
    form = HTTP::FormData::Multipart.new({ 123 => part }, boundary: "b")
    body = form.to_s

    assert_includes body, 'name="123"'
  end

  # Kill: @part = if v.is_a?(FormData::Part) then value else FormData::Part.new(value)
  # Non-Part values get wrapped in Part
  def test_param_wraps_non_part_value
    form = HTTP::FormData::Multipart.new({ foo: "raw_string" }, boundary: "b")
    body = form.to_s

    assert_includes body, "raw_string"
    refute_includes body, "Content-Type:"
  end

  # Part values are used as-is
  def test_param_uses_part_directly
    part = HTTP::FormData::Part.new("part_body", content_type: "text/plain")
    form = HTTP::FormData::Multipart.new({ foo: part }, boundary: "b")
    body = form.to_s

    assert_includes body, "part_body"
    assert_includes body, "Content-Type: text/plain"
  end

  # --- Kill mutations for Multipart::Param#header ---

  # Kill: header << "Content-Disposition: form-data; #{parameters}#{CRLF}"
  def test_param_header_contains_content_disposition
    form = HTTP::FormData::Multipart.new({ myfield: "val" }, boundary: "b")
    body = form.to_s

    assert_includes body, "Content-Disposition: form-data; name=\"myfield\""
  end

  # Kill: header << "Content-Type: #{content_type}#{CRLF}" if content_type
  def test_param_header_includes_content_type_when_present
    part = HTTP::FormData::Part.new("val", content_type: "application/json")
    form = HTTP::FormData::Multipart.new({ f: part }, boundary: "b")
    body = form.to_s

    assert_includes body, "Content-Type: application/json\r\n"
  end

  def test_param_header_excludes_content_type_when_nil
    part = HTTP::FormData::Part.new("val")
    form = HTTP::FormData::Multipart.new({ f: part }, boundary: "b")
    body = form.to_s

    refute_includes body, "Content-Type:"
  end

  # --- Kill mutations for Multipart::Param#footer ---

  # Kill: CRLF.dup replaced with nil or other
  # Verify that each part ends with CRLF
  def test_param_footer_is_crlf
    form = HTTP::FormData::Multipart.new({ f: "v" }, boundary: "b")
    body = form.to_s

    # The structure should be: --b\r\n<header>\r\n<value>\r\n--b--\r\n
    # Each part body is followed by CRLF (the footer)
    assert_includes body, "v\r\n--b--"
  end
end
