# frozen_string_literal: true

require "http/form_data/readable"
require "http/form_data/composite_io"

module HTTP
  module FormData
    class Multipart
      # Utility class to represent multi-part chunks
      class Param
        include Readable

        # Initializes body part with headers and data
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
        # @api public
        # @param [#to_s] name
        # @param [FormData::File, FormData::Part, #to_s] value
        # @return [Param]
        def initialize(name, value)
          @name = name.to_s

          @part =
            if value.is_a?(FormData::Part)
              value
            else
              FormData::Part.new(value)
            end

          @io = CompositeIO.new [header, @part, footer]
        end

        private

        # Builds the MIME header for this part
        #
        # @api private
        # @return [String]
        def header
          header = "".b
          header << "Content-Disposition: form-data; #{parameters}#{CRLF}"
          header << "Content-Type: #{content_type}#{CRLF}" if content_type
          header << CRLF
          header
        end

        # Builds Content-Disposition parameters string
        #
        # @api private
        # @return [String]
        def parameters
          parameters = { name: @name }
          parameters[:filename] = filename if filename
          parameters.map { |k, v| "#{k}=#{v.inspect}" }.join("; ")
        end

        # Returns the content type of the wrapped part
        #
        # @api private
        # @return [String, nil]
        def content_type
          @part.content_type
        end

        # Returns the filename of the wrapped part
        #
        # @api private
        # @return [String, nil]
        def filename
          @part.filename
        end

        # Returns the CRLF footer
        #
        # @api private
        # @return [String]
        def footer
          CRLF.dup
        end
      end
    end
  end
end
