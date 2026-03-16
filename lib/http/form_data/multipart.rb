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

      attr_reader :boundary

      # @param [Enumerable, Hash, #to_h] data form data key-value pairs
      def initialize(data, boundary: self.class.generate_boundary)
        @boundary = boundary.to_s.freeze
        @io = CompositeIO.new(parts(data).flat_map { |part| [glue, part] } << tail)
      end

      # Generates a string suitable for using as a boundary in multipart form
      # data.
      #
      # @return [String]
      def self.generate_boundary
        ("-" * 21) << SecureRandom.hex(21)
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
      alias content_length size

      private

      # @return [String]
      def glue
        @glue ||= "--#{@boundary}#{CRLF}"
      end

      # @return [String]
      def tail
        @tail ||= "--#{@boundary}--#{CRLF}"
      end

      def parts(data)
        params = []

        FormData.ensure_data(data).each do |name, values|
          Array(values).each do |value|
            params << Param.new(name, value)
          end
        end

        params
      end
    end
  end
end
