# frozen_string_literal: true

module HTTP
  module FormData
    class Multipart
      # Utility class to represent multi-part chunks
      class Param
        # @param [#to_s] name
        # @param [FormData::File, #to_s] value
        def initialize(name, value)
          mime    = value.mime_type if value.respond_to?(:mime_type)
          params  = ["name=#{name.to_s.inspect}"]

          if value.is_a? FormData::File
            @value = value
            params << "filename=#{value.filename.inspect}"
          else
            @value = value.to_s
          end

          @header = "Content-Disposition: form-data; #{params.join '; '}" \
                    "#{CRLF}Content-Type: #{mime || DEFAULT_MIME}"
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

          if @value.is_a? FormData::File
            size + @value.size
          else
            size + @value.bytesize
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
      end
    end
  end
end
