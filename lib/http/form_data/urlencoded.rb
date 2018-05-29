# frozen_string_literal: true

require "http/form_data/readable"
require "http/form_data/configuration"

require "uri"
require "stringio"

module HTTP
  module FormData
    # `application/x-www-form-urlencoded` form data.
    class Urlencoded
      include Readable

      # @param [#to_h, Hash] data form data key-value Hash
      def initialize(data)
        encoded_data = encode(data)
        @io = StringIO.new(encoded_data)
      end

      # Returns MIME type to be used for HTTP request `Content-Type` header.
      #
      # @return [String]
      def content_type
        "application/x-www-form-urlencoded"
      end

      # Returns form data content size to be used for HTTP request
      # `Content-Length` header.
      #
      # @return [Integer]
      alias content_length size

      # @param [#to_h, Hash] data form data key-value Hash
      def encode(data)
        HTTP::FormData.configuration.encoding_method.call(data)
      end
    end
  end
end
