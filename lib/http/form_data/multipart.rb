# frozen_string_literal: true

require "securerandom"

require "http/form_data/multipart/param"
require "http/form_data/readable"
require "http/form_data/composite_io"

module HTTP
  module FormData
    # `multipart/form-data` form data.
    class Multipart
      include Readable

      # @param [#to_h, Hash] data form data key-value Hash
      def initialize(data)
        parts = Param.coerce FormData.ensure_hash data

        @boundary = ("-" * 21) << SecureRandom.hex(21)
        @io = CompositeIO.new(*parts.flat_map { |part| [glue, part] }, tail)
      end

      # Returns MIME type to be used for HTTP request `Content-Type` header.
      #
      # @return [String]
      def content_type
        "multipart/form-data; boundary=#{@boundary}"
      end

      # Returns form data content size to be used for HTTP request
      # `Content-Length` header.
      #
      # @return [Integer]
      def content_length
        size
      end

      private

      # @return [String]
      def glue
        @glue ||= "--#{@boundary}#{CRLF}"
      end

      # @return [String]
      def tail
        @tail ||= "--#{@boundary}--"
      end
    end
  end
end
