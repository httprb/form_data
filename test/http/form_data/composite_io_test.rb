# frozen_string_literal: true

require "test_helper"

class CompositeIOTest < Minitest::Test
  include FixturesHelper

  def setup
    @ios = ["Hello", " ", "", "world", "!"].map { |s| StringIO.new(s) }
    @composite_io = HTTP::FormData::CompositeIO.new(@ios)
  end

  def test_accepts_ios_and_strings
    io = HTTP::FormData::CompositeIO.new(["Hello ", StringIO.new("world!")])

    assert_equal "Hello world!", io.read
  end

  def test_fails_if_io_is_neither_string_nor_io
    assert_raises(ArgumentError) { HTTP::FormData::CompositeIO.new(%i[hello world]) }
  end

  def test_reads_all_data
    assert_equal "Hello world!", @composite_io.read
  end

  def test_reads_partial_data
    assert_equal "Hel", @composite_io.read(3)
    assert_equal "lo", @composite_io.read(2)
    assert_equal " ", @composite_io.read(1)
    assert_equal "world!", @composite_io.read(6)
  end

  def test_returns_empty_string_when_no_data_retrieved
    @composite_io.read

    assert_equal "", @composite_io.read
  end

  def test_returns_nil_when_no_partial_data_retrieved
    @composite_io.read

    assert_nil @composite_io.read(3)
  end

  def test_reads_partial_data_with_buffer
    outbuf = +""

    assert_equal "Hel", @composite_io.read(3, outbuf)
    assert_equal "lo", @composite_io.read(2, outbuf)
    assert_equal " ", @composite_io.read(1, outbuf)
    assert_equal "world!", @composite_io.read(6, outbuf)
  end

  def test_fills_buffer_with_retrieved_content
    outbuf = +""
    @composite_io.read(3, outbuf)

    assert_equal "Hel", outbuf
    @composite_io.read(2, outbuf)

    assert_equal "lo", outbuf
    @composite_io.read(1, outbuf)

    assert_equal " ", outbuf
    @composite_io.read(6, outbuf)

    assert_equal "world!", outbuf
  end

  def test_returns_nil_when_no_partial_data_retrieved_with_buffer
    outbuf = +"content"
    @composite_io.read

    assert_nil @composite_io.read(3, outbuf)
    assert_equal "", outbuf
  end

  def test_returns_data_in_binary_encoding
    io = HTTP::FormData::CompositeIO.new(%w[Janko Marohnić])

    assert_equal Encoding::BINARY, io.read(5).encoding
    assert_equal Encoding::BINARY, io.read(9).encoding

    io.rewind

    assert_equal Encoding::BINARY, io.read.encoding
    assert_equal Encoding::BINARY, io.read.encoding
  end

  def test_reads_data_in_bytes
    emoji = "😃"
    io = HTTP::FormData::CompositeIO.new([emoji])

    assert_equal emoji.b[0], io.read(1)
    assert_equal emoji.b[1], io.read(1)
    assert_equal emoji.b[2], io.read(1)
    assert_equal emoji.b[3], io.read(1)
  end

  def test_rewinds_all_ios
    @composite_io.read
    @composite_io.rewind

    assert_equal "Hello world!", @composite_io.read
  end

  def test_returns_sum_of_all_io_sizes
    assert_equal 12, @composite_io.size
  end

  def test_returns_zero_when_no_ios
    empty = HTTP::FormData::CompositeIO.new([])

    assert_equal 0, empty.size
  end
end
