# frozen_string_literal: true

module HTTP
  module FormData
    class Part
      attr_reader :mime_type, :filename

      # @param [#to_s] body
      # @param [String] :mime_type
      # @param [String] :filename
      def initialize(body, mime_type: nil, filename: nil)
        @body = body.to_s
        @mime_type = mime_type
        @filename = filename
      end

      # Returns content size.
      #
      # @return [Integer]
      def size
        @body.bytesize
      end

      # Returns content of a file of IO.
      #
      # @return [String]
      def to_s
        @body
      end
    end
  end
end
