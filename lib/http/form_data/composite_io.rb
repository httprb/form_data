# frozen_string_literal: true

module HTTP
  module FormData
    # Provides IO interface across multiple IO files.
    class CompositeIO
      # @param [Array<IO>] ios Array of IO objects
      def initialize(*ios)
        @ios = ios.flatten
        @index = 0
      end

      # Reads and returns list of 
      #
      # @param [Integer] length Number of bytes to retrieve
      # @param [String] outbuf String to be replaced with retrieved data
      #
      # @return [String]
      def read(length = nil, outbuf = nil)
        outbuf = outbuf.to_s.replace("")

        while current_io
          data = current_io.read(length)
          outbuf << data.to_s
          length -= data.to_s.length if length

          break if length == 0

          advance_io
        end

        return nil if length && outbuf.empty?

        outbuf
      end

      def rewind
        @ios.each(&:rewind)
        @index = 0
      end

      def size
        @size ||= @ios.map(&:size).inject(0, :+)
      end

      private

      def current_io
        @ios[@index]
      end

      def advance_io
        @index += 1
      end
    end
  end
end
