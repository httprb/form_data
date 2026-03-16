# frozen_string_literal: true

require "test_helper"

class FormDataFileTest < Minitest::Test
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
end
