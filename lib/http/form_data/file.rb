module HTTP
  module FormData
    # Represents file form param.
    #
    # @example Usage with StringIO
    #
    #  io = StringIO.new "foo bar baz"
    #  FormData::File.new io, :filename => "foobar.txt"
    #
    # @example Usage with IO
    #
    #  File.open "/home/ixti/avatar.png" do |io|
    #    FormData::File.new io
    #  end
    #
    # @example Usage with pathname
    #
    #  FormData::File.new "/home/ixti/avatar.png"
    class File
      # Default MIME type
      DEFAULT_MIME = "application/octet-stream".freeze

      attr_reader :mime_type, :filename

      # @see DEFAULT_MIME
      # @param [String, StringIO, File] file_or_io Filename or IO instance.
      # @param [#to_h] opts
      # @option opts [#to_s] :mime_type (DEFAULT_MIME)
      # @option opts [#to_s] :filename
      #   When `file` is a String, defaults to basename of `file`.
      #   When `file` is a File, defaults to basename of `file`.
      #   When `file` is a StringIO, defaults to `"stream-{object_id}"`
      def initialize(file_or_io, opts = {})
        @file_or_io = file_or_io

        opts = FormData.ensure_hash opts

        @mime_type  = opts.fetch(:mime_type) { DEFAULT_MIME }
        @filename   = opts.fetch :filename do
          case file_or_io
          when String then ::File.basename file_or_io
          when ::File then ::File.basename file_or_io.path
          else             "stream-#{file_or_io.object_id}"
          end
        end
      end

      # Returns content size.
      #
      # @return [Fixnum]
      def size
        with_io(&:size)
      end

      # Returns content of a file of IO.
      #
      # @return [String]
      def to_s
        with_io(&:read)
      end

      private

      # @yield [io] Gives IO instance to the block
      # @return result of yielded block
      def with_io
        if @file_or_io.is_a?(::File) || @file_or_io.is_a?(StringIO)
          yield @file_or_io
        else
          ::File.open(@file_or_io) { |io| yield io }
        end
      end
    end
  end
end
