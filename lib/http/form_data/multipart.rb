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

      # Returns the multipart boundary string
      #
      # @example
      #   multipart.boundary # => "-----abc123"
      #
      # @api public
      # @return [String]
      attr_reader :boundary

      # Creates a new Multipart form data instance
      #
      # @example
      #   Multipart.new({ foo: "bar" })
      #
      # @api public
      # @param [Enumerable, Hash, #to_h] data form data key-value pairs
      # @param [String] boundary custom boundary string
      def initialize(data, boundary: self.class.generate_boundary)
        @boundary = boundary.to_s.freeze
        @io = CompositeIO.new(parts(data).flat_map { |part| [glue, part] } << tail)
      end

      # Generates a boundary string for multipart form data
      #
      # @example
      #   Multipart.generate_boundary # => "-----abc123..."
      #
      # @api public
      # @return [String]
      def self.generate_boundary
        ("-" * 21) << SecureRandom.hex(21)
      end

      # Returns MIME type for the Content-Type header
      #
      # @example
      #   multipart.content_type
      #   # => "multipart/form-data; boundary=-----abc123"
      #
      # @api public
      # @return [String]
      def content_type
        "multipart/form-data; boundary=#{@boundary}"
      end

      # Returns form data content size for Content-Length
      #
      # @example
      #   multipart.content_length # => 123
      #
      # @api public
      # @return [Integer]
      alias content_length size

      private

      # Returns the boundary glue between parts
      #
      # @api private
      # @return [String]
      def glue
        @glue ||= "--#{@boundary}#{CRLF}"
      end

      # Returns the closing boundary tail
      #
      # @api private
      # @return [String]
      def tail
        @tail ||= "--#{@boundary}--#{CRLF}"
      end

      # Coerces data into an array of Param objects
      #
      # @api private
      # @return [Array<Param>]
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
