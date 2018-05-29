# frozen_string_literal: true

require "http/form_data/readable"

require "uri"
require "stringio"

module HTTP
  module FormData
    # `application/x-www-form-urlencoded` form data.
    class Urlencoded
      include Readable

      class << self
        attr_writer :encoder

        def encoder
          @encoder ||= ::URI.method(:encode_www_form)
        end
      end

      # @param [#to_h, Hash] data form data key-value Hash
      def initialize(data)
        @io = StringIO.new(self.class.encoder.call(FormData.ensure_hash(data)))
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
    end
  end
end
