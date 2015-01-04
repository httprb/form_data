module HTTP
  module FormData
    class Multipart
      # Utility class to represent multi-part chunks
      class Param
        # @param [#to_s] name
        # @param [FormData::File, #to_s] value
        def initialize(name, value)
          @name, @value = name.to_s, value

          @header = "Content-Disposition: form-data; name=#{@name.inspect}"

          return unless file?

          @header << "; filename=#{value.filename.inspect}"
          @header << CRLF
          @header << "Content-Type: #{value.mime_type}"
        end

        # Returns body part with headers and data.
        #
        # @example With {FormData::File} value
        #
        #   Content-Disposition: form-data; name="avatar"; filename="avatar.png"
        #   Content-Type: application/octet-stream
        #
        #   ...data of avatar.png...
        #
        # @example With non-{FormData::File} value
        #
        #   Content-Disposition: form-data; name="username"
        #
        #   ixti
        #
        # @return [String]
        def to_s
          "#{@header}#{CRLF * 2}#{@value}"
        end

        # Calculates size of a part (headers + body).
        #
        # @return [Fixnum]
        def size
          size = @header.bytesize + (CRLF.bytesize * 2)

          if file?
            size + @value.size
          else
            size + @value.to_s.bytesize
          end
        end

        # Flattens given `data` Hash into an array of `Param`'s.
        # Nested array are unwinded.
        # Behavior is similar to `URL.encode_www_form`.
        #
        # @param [Hash] data
        # @return [Array<FormData::MultiPart::Param>]
        def self.coerce(data)
          params = []

          data.each do |name, values|
            Array(values).each do |value|
              params << new(name, value)
            end
          end

          params
        end

        private

        # Tells whenever value is a {FormData::File} or not.
        #
        # @return [Boolean]
        def file?
          @value.is_a? FormData::File
        end
      end
    end
  end
end
