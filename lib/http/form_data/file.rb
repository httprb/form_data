# frozen_string_literal: true

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
    class File < Part
      # Default MIME type
      DEFAULT_MIME = "application/octet-stream"

      # @deprecated Use #content_type instead
      alias mime_type content_type

      # @see DEFAULT_MIME
      # @param [String, Pathname, IO] file_or_io Filename or IO instance.
      # @param [#to_h] opts
      # @option opts [#to_s] :content_type (DEFAULT_MIME)
      #   Value of Content-Type header
      # @option opts [#to_s] :filename
      #   When `file` is a String, defaults to basename of `file`.
      #   When `file` is a File, defaults to basename of `file`.
      #   When `file` is a StringIO, defaults to `"stream-{object_id}"`
      def initialize(path_or_io, opts = {})
        opts = FormData.ensure_hash(opts)

        if opts.key? :mime_type
          warn "[DEPRECATED] :mime_type option deprecated, use :content_type"
          opts[:content_type] = opts[:mime_type]
        end

        if path_or_io.is_a?(String) || defined?(Pathname) && path_or_io.is_a?(Pathname)
          @io = ::File.open(path_or_io, binmode: true)
        else
          @io = path_or_io
        end

        @content_type = opts.fetch(:content_type, DEFAULT_MIME).to_s
        @filename     = opts.fetch :filename do
          if @io.is_a?(::File)
            ::File.basename @io.path
          else
            "stream-#{@io.object_id}"
          end
        end
      end

      # Returns content size.
      #
      # @return [Integer]
      def size
        @io.size
      end

      # Returns content of the IO.
      #
      # @return [String]
      def to_s
        @io.read
      end
    end
  end
end
