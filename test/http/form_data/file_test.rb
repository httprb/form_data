# frozen_string_literal: true

require "test_helper"

class FormDataFileTest < Minitest::Test
  cover "HTTP::FormData::File*"
  include FixturesHelper

  def test_size_with_string_path
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info").to_s)

    assert_equal fixture("the-http-gem.info").size, form_file.size
  end

  def test_size_with_pathname
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info"))

    assert_equal fixture("the-http-gem.info").size, form_file.size
  end

  def test_size_with_file
    file = fixture("the-http-gem.info").open
    form_file = HTTP::FormData::File.new(file)

    assert_equal fixture("the-http-gem.info").size, form_file.size
  ensure
    file.close
  end

  def test_size_with_io
    form_file = HTTP::FormData::File.new(StringIO.new("привет мир!"))

    assert_equal 20, form_file.size
  end

  def test_to_s_with_string_path
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info").to_s)

    assert_equal fixture("the-http-gem.info").read(mode: "rb"), form_file.to_s
  end

  def test_to_s_with_pathname
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info"))

    assert_equal fixture("the-http-gem.info").read(mode: "rb"), form_file.to_s
  end

  def test_to_s_with_file
    file = fixture("the-http-gem.info").open("rb")
    form_file = HTTP::FormData::File.new(file)

    assert_equal fixture("the-http-gem.info").read(mode: "rb"), form_file.to_s
  ensure
    file.close
  end

  def test_to_s_with_io
    form_file = HTTP::FormData::File.new(StringIO.new("привет мир!"))

    assert_equal "привет мир!", form_file.to_s
  end

  def test_to_s_rewinds_content_with_string_path
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info").to_s)
    content = form_file.read

    assert_equal content, form_file.to_s
    assert_equal content, form_file.read
  end

  def test_to_s_rewinds_content_with_pathname
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info"))
    content = form_file.read

    assert_equal content, form_file.to_s
    assert_equal content, form_file.read
  end

  def test_to_s_rewinds_content_with_file
    file = fixture("the-http-gem.info").open("rb")
    form_file = HTTP::FormData::File.new(file)
    content = form_file.read

    assert_equal content, form_file.to_s
    assert_equal content, form_file.read
  ensure
    file.close
  end

  def test_to_s_rewinds_content_with_io
    form_file = HTTP::FormData::File.new(StringIO.new("привет мир!"))
    content = form_file.read

    assert_equal content, form_file.to_s
    assert_equal content, form_file.read
  end

  def test_read_with_string_path
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info").to_s)

    assert_equal fixture("the-http-gem.info").read(mode: "rb"), form_file.read
  end

  def test_read_with_pathname
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info"))

    assert_equal fixture("the-http-gem.info").read(mode: "rb"), form_file.read
  end

  def test_read_with_file
    file = fixture("the-http-gem.info").open("rb")
    form_file = HTTP::FormData::File.new(file)

    assert_equal fixture("the-http-gem.info").read(mode: "rb"), form_file.read
  ensure
    file.close
  end

  def test_read_with_io
    form_file = HTTP::FormData::File.new(StringIO.new("привет мир!"))

    assert_equal "привет мир!", form_file.read
  end

  def test_rewind_with_string_path
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info").to_s)
    content = form_file.read
    form_file.rewind

    assert_equal content, form_file.read
  end

  def test_rewind_with_pathname
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info"))
    content = form_file.read
    form_file.rewind

    assert_equal content, form_file.read
  end

  def test_rewind_with_file
    file = fixture("the-http-gem.info").open("rb")
    form_file = HTTP::FormData::File.new(file)
    content = form_file.read
    form_file.rewind

    assert_equal content, form_file.read
  ensure
    file.close
  end

  def test_rewind_with_io
    form_file = HTTP::FormData::File.new(StringIO.new("привет мир!"))
    content = form_file.read
    form_file.rewind

    assert_equal content, form_file.read
  end

  def test_filename_with_string_path
    path = fixture("the-http-gem.info").to_s
    form_file = HTTP::FormData::File.new(path)

    assert_equal File.basename(path), form_file.filename
  end

  def test_filename_with_string_path_and_option
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info").to_s, filename: "foobar.txt")

    assert_equal "foobar.txt", form_file.filename
  end

  def test_filename_with_pathname
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info"))

    assert_equal "the-http-gem.info", form_file.filename
  end

  def test_filename_with_pathname_and_option
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info"), filename: "foobar.txt")

    assert_equal "foobar.txt", form_file.filename
  end

  def test_filename_with_file
    file = fixture("the-http-gem.info").open
    form_file = HTTP::FormData::File.new(file)

    assert_equal "the-http-gem.info", form_file.filename
  ensure
    file.close
  end

  def test_filename_with_file_and_option
    file = fixture("the-http-gem.info").open
    form_file = HTTP::FormData::File.new(file, filename: "foobar.txt")

    assert_equal "foobar.txt", form_file.filename
  ensure
    file.close
  end

  def test_filename_with_io
    io = StringIO.new
    form_file = HTTP::FormData::File.new(io)

    assert_equal "stream-#{io.object_id}", form_file.filename
  end

  def test_filename_with_io_and_option
    form_file = HTTP::FormData::File.new(StringIO.new, filename: "foobar.txt")

    assert_equal "foobar.txt", form_file.filename
  end

  def test_content_type_default
    form_file = HTTP::FormData::File.new(StringIO.new)

    assert_equal "application/octet-stream", form_file.content_type
  end

  def test_content_type_with_option
    form_file = HTTP::FormData::File.new(StringIO.new, content_type: "application/json")

    assert_equal "application/json", form_file.content_type
  end

  def test_deprecated_mime_type_option
    assert_output(nil, /DEPRECATED/) do
      form_file = HTTP::FormData::File.new(StringIO.new, mime_type: "application/json")

      assert_equal "application/json", form_file.content_type
    end
  end

  def test_mime_type_is_alias_of_content_type
    assert_equal(
      HTTP::FormData::File.instance_method(:content_type),
      HTTP::FormData::File.instance_method(:mime_type)
    )
  end

  # --- Kill mutations for File#initialize ---

  # Kill: @io = make_io(path_or_io) replaced with @io = path_or_io
  # String path should be readable (make_io opens it)
  def test_initialize_string_path_creates_readable_io
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info").to_s)
    content = form_file.read

    refute_nil content
    refute_empty content
  end

  # Kill: @content_type = opts.fetch(:content_type, DEFAULT_MIME).to_s
  # Verify content_type defaults to DEFAULT_MIME
  def test_content_type_defaults_to_default_mime
    form_file = HTTP::FormData::File.new(StringIO.new("data"))

    assert_equal HTTP::FormData::File::DEFAULT_MIME, form_file.content_type
    assert_equal "application/octet-stream", form_file.content_type
  end

  # Kill: content_type .to_s mutation — verify non-string content_type is converted
  def test_content_type_converts_to_string
    form_file = HTTP::FormData::File.new(StringIO.new("data"), content_type: :json)

    assert_equal "json", form_file.content_type
    assert_instance_of String, form_file.content_type
  end

  # Kill: @filename = opts.fetch(:filename, filename_for(@io))
  # Verify filename is correctly set from IO path
  def test_filename_from_string_path_uses_basename
    path = fixture("the-http-gem.info").to_s
    form_file = HTTP::FormData::File.new(path)

    assert_equal "the-http-gem.info", form_file.filename
  end

  # Kill: opts = FormData.ensure_hash(opts) replaced with opts = opts
  # Verify nil opts works (ensure_hash converts nil to {})
  def test_initialize_with_nil_opts
    form_file = HTTP::FormData::File.new(StringIO.new("data"), nil)

    assert_equal "application/octet-stream", form_file.content_type
  end

  # --- Kill mutations for File#make_io ---

  # Kill: path_or_io.is_a?(String) mutations
  # Verify String path opens a file that can be read
  def test_make_io_with_string_opens_file
    path = fixture("the-http-gem.info").to_s
    form_file = HTTP::FormData::File.new(path)
    expected = File.read(path, mode: "rb")

    assert_equal expected, form_file.to_s
  end

  # Kill: defined?(Pathname) && path_or_io.is_a?(Pathname) mutations
  # Verify Pathname opens a file that can be read
  def test_make_io_with_pathname_opens_file
    pathname = fixture("the-http-gem.info")
    form_file = HTTP::FormData::File.new(pathname)
    expected = pathname.read(mode: "rb")

    assert_equal expected, form_file.to_s
  end

  # Kill: path_or_io.is_a?(String) replaced with path_or_io.instance_of?(String)
  # String subclass should also be opened as a file
  def test_make_io_with_string_subclass
    str_subclass = Class.new(String)
    path = str_subclass.new(fixture("the-http-gem.info").to_s)
    form_file = HTTP::FormData::File.new(path)

    assert_equal File.read(fixture("the-http-gem.info").to_s, mode: "rb"), form_file.to_s
  end

  # Kill: path_or_io.instance_of?(Pathname) vs is_a?(Pathname)
  # Pathname subclass should also be opened via the Pathname path
  def test_make_io_with_pathname_subclass
    subclass = Class.new(Pathname)
    pathname = subclass.new(fixture("the-http-gem.info").to_s)
    form_file = HTTP::FormData::File.new(pathname)

    assert_equal fixture("the-http-gem.info").read(mode: "rb"), form_file.to_s
  end

  # Kill: else branch — IO is used as-is
  def test_make_io_with_io_uses_directly
    io = StringIO.new("direct io content")
    form_file = HTTP::FormData::File.new(io)

    assert_equal "direct io content", form_file.to_s
  end

  # Kill: ::File.open(path_or_io, binmode: true) replaced with other
  # Verify that file opened from string path is in binary mode
  def test_make_io_string_path_opens_in_binmode
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info").to_s)
    content = form_file.read

    assert_equal Encoding::ASCII_8BIT, content.encoding
  end

  # Kill: path_or_io.open(binmode: true) replaced with other
  # Verify that file opened from Pathname is in binary mode
  def test_make_io_pathname_opens_in_binmode
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info"))
    content = form_file.read

    assert_equal Encoding::ASCII_8BIT, content.encoding
  end

  # --- Kill mutations for File#filename_for ---

  # Kill: io.respond_to?(:path) replaced with nil/false
  def test_filename_for_io_with_path
    file = fixture("the-http-gem.info").open
    form_file = HTTP::FormData::File.new(file)

    assert_equal "the-http-gem.info", form_file.filename
    assert_respond_to file, :path
  ensure
    file.close
  end

  # Kill: "stream-#{io.object_id}" replaced with other
  def test_filename_for_io_without_path
    io = StringIO.new("data")
    form_file = HTTP::FormData::File.new(io)

    assert_equal "stream-#{io.object_id}", form_file.filename
    assert_match(/\Astream-\d+\z/, form_file.filename)
  end

  # Kill: ::File.basename io.path replaced with other
  def test_filename_for_uses_basename_not_full_path
    path = fixture("the-http-gem.info").to_s
    form_file = HTTP::FormData::File.new(path)

    refute_includes form_file.filename, "/"
    assert_equal "the-http-gem.info", form_file.filename
  end

  # --- Kill Readable#read mutations via File ---

  # Kill: @io.read(length, outbuf) replaced with @io.read(length) etc
  def test_read_with_length_returns_partial_content
    form_file = HTTP::FormData::File.new(StringIO.new("hello world"))
    result = form_file.read(5)

    assert_equal "hello", result
  end

  def test_read_with_nil_length_returns_all_content
    form_file = HTTP::FormData::File.new(StringIO.new("hello world"))
    result = form_file.read(nil)

    assert_equal "hello world", result
  end

  def test_read_with_length_and_outbuf
    form_file = HTTP::FormData::File.new(StringIO.new("hello world"))
    outbuf = +""
    result = form_file.read(5, outbuf)

    assert_equal "hello", result
    assert_equal "hello", outbuf
  end

  def test_read_after_eof_returns_nil_with_length
    form_file = HTTP::FormData::File.new(StringIO.new("hi"))
    form_file.read

    assert_nil form_file.read(1)
  end

  def test_read_after_eof_returns_empty_string_without_length
    form_file = HTTP::FormData::File.new(StringIO.new("hi"))
    form_file.read

    assert_equal "", form_file.read
  end

  # --- File#close ---

  def test_close_with_string_path_closes_io
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info").to_s)
    form_file.read
    form_file.close

    assert_raises(IOError) { form_file.read }
  end

  def test_close_with_pathname_closes_io
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info"))
    form_file.read
    form_file.close

    assert_raises(IOError) { form_file.read }
  end

  def test_close_with_io_does_not_close
    io = StringIO.new("hello")
    form_file = HTTP::FormData::File.new(io)
    form_file.close

    assert_equal "hello", io.read
  end

  def test_close_is_idempotent
    form_file = HTTP::FormData::File.new(fixture("the-http-gem.info").to_s)
    form_file.close
    form_file.close
  end

  def test_close_with_string_subclass_closes_io
    str_subclass = Class.new(String)
    form_file = HTTP::FormData::File.new(str_subclass.new(fixture("the-http-gem.info").to_s))
    form_file.read
    form_file.close

    assert_raises(IOError) { form_file.read }
  end

  def test_close_with_pathname_subclass_closes_io
    pathname_subclass = Class.new(Pathname)
    form_file = HTTP::FormData::File.new(pathname_subclass.new(fixture("the-http-gem.info").to_s))
    form_file.read
    form_file.close

    assert_raises(IOError) { form_file.read }
  end
end
