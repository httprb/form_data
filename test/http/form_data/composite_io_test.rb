# frozen_string_literal: true

require "test_helper"

class CompositeIOTest < Minitest::Test
  cover "HTTP::FormData::CompositeIO*"
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
    error = assert_raises(ArgumentError) { HTTP::FormData::CompositeIO.new(%i[hello world]) }

    assert_includes error.message, ":hello"
    assert_includes error.message, "is neither a String nor an IO object"
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

  # --- Kill mutations for CompositeIO#initialize ---

  # Kill: replacing io.is_a?(String) with nil/false/self.is_a?(String)/io.instance_of?(String)
  # Verify that a String subclass is also converted to StringIO
  def test_initialize_converts_string_subclass_to_io
    str_subclass = Class.new(String)
    io = HTTP::FormData::CompositeIO.new([str_subclass.new("hello")])

    assert_equal "hello", io.read
  end

  # Kill: replacing io.respond_to?(:read) with nil/false
  # Verify that an object responding to :read is accepted as-is
  def test_initialize_accepts_custom_io_object
    custom_io = Class.new do
      def initialize
        @done = false
      end

      def read(length = nil, outbuf = nil)
        if @done
          length ? nil : ""
        else
          @done = true
          result = +"custom"
          if outbuf
            outbuf.replace(result)
            outbuf
          else
            result
          end
        end
      end

      def size = 6

      def rewind
        @done = false
      end
    end.new

    io = HTTP::FormData::CompositeIO.new([custom_io])

    assert_equal "custom", io.read
  end

  # Kill: @index = 0 replaced with @index = nil or removed
  def test_initialize_starts_reading_from_beginning
    io = HTTP::FormData::CompositeIO.new(%w[abc def])

    assert_equal "a", io.read(1)
  end

  # Kill: @buffer = "".b replaced with something else
  def test_read_partial_uses_internal_buffer_correctly
    io = HTTP::FormData::CompositeIO.new(%w[abc def])

    assert_equal "ab", io.read(2)
    assert_equal "cd", io.read(2)
    assert_equal "ef", io.read(2)
  end

  # Kill: replacing current_io with nil or other mutation
  def test_current_io_returns_nil_after_all_read
    io = HTTP::FormData::CompositeIO.new(["a"])
    io.read

    assert_nil io.read(1)
  end

  # --- Kill mutations for CompositeIO#read ---

  # Kill: data unless length && data.empty? — various mutations
  # When reading all with no length and there IS data
  def test_read_without_length_returns_string
    io = HTTP::FormData::CompositeIO.new(["hello"])
    result = io.read

    assert_instance_of String, result
    assert_equal "hello", result
  end

  # When reading all with no length and NO data left
  def test_read_without_length_returns_empty_string_when_exhausted
    io = HTTP::FormData::CompositeIO.new(["hello"])
    io.read
    result = io.read

    assert_instance_of String, result
    assert_equal "", result
  end

  # When reading with length and NO data left
  def test_read_with_length_returns_nil_when_exhausted
    io = HTTP::FormData::CompositeIO.new(["hello"])
    io.read
    result = io.read(5)

    assert_nil result
  end

  # --- Kill mutations for CompositeIO#readpartial ---

  # Kill: chunk && !chunk.empty? mutations
  # Read across IO boundary with exact length
  def test_readpartial_advances_through_ios
    io = HTTP::FormData::CompositeIO.new(%w[ab cd ef])

    assert_equal "abcdef", io.read
  end

  # Kill: chunk = current_io.read(max_length, @buffer) mutations
  def test_readpartial_with_empty_io_in_middle
    io = HTTP::FormData::CompositeIO.new(["ab", "", "cd"])

    assert_equal "abcd", io.read
  end

  # --- Kill mutations for CompositeIO#read_chunks ---

  # Kill: next if length.nil? replaced with other
  # Kill: length -= chunk.bytesize mutations
  # Kill: break if length.zero? mutations
  def test_read_chunks_respects_length_exactly
    io = HTTP::FormData::CompositeIO.new(%w[abcdef ghijkl])

    assert_equal "abc", io.read(3)
    assert_equal "def", io.read(3)
    assert_equal "ghi", io.read(3)
    assert_equal "jkl", io.read(3)
    assert_nil io.read(1)
  end

  def test_read_chunks_length_spanning_ios
    io = HTTP::FormData::CompositeIO.new(%w[ab cd ef])

    assert_equal "abcd", io.read(4)
    assert_equal "ef", io.read(4)
  end

  # Kill: read with outbuf and no length
  def test_read_all_with_outbuf
    outbuf = +""
    io = HTTP::FormData::CompositeIO.new(["hello", " ", "world"])
    result = io.read(nil, outbuf)

    assert_equal "hello world", result
    assert_equal "hello world", outbuf
    assert_same result, outbuf
  end

  # Verify outbuf is cleared before use
  def test_read_with_outbuf_clears_previous_content
    outbuf = +"previous content"
    io = HTTP::FormData::CompositeIO.new(["new"])
    io.read(nil, outbuf)

    assert_equal "new", outbuf
  end

  # Kill: outbuf.clear.force_encoding(Encoding::BINARY) -> outbuf.clear
  # Verify that outbuf encoding is forced to binary
  def test_read_with_utf8_outbuf_returns_binary_encoding
    outbuf = +"hello"
    outbuf.force_encoding(Encoding::UTF_8)
    io = HTTP::FormData::CompositeIO.new(%w[Marohnić])
    io.read(5, outbuf)

    assert_equal Encoding::BINARY, outbuf.encoding
  end

  # Kill: error message mutation — io.inspect vs io vs nil vs self.inspect
  def test_error_message_contains_inspect_of_invalid_io
    obj = Object.new
    def obj.inspect = "INVALID_IO_INSPECT"
    def obj.to_s = "INVALID_IO_TO_S"

    error = assert_raises(ArgumentError) { HTTP::FormData::CompositeIO.new([obj]) }

    assert_includes error.message, "INVALID_IO_INSPECT"
  end
end
