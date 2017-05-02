# frozen_string_literal: true

require "stringio"

require "http/form_data/readable"
require "http/form_data/composite_io"

module HTTP
  module FormData
    class Multipart
      # Utility class to represent multi-part chunks
      class Param
        include Readable

        # Initializes body part with headers and data.
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
        # @param [#to_s] name
        # @param [FormData::File, FormData::Part, #to_s] value
        def initialize(name, value)
          part =
            if value.is_a?(FormData::Part)
              value
            else
              FormData::Part.new(value)
            end

          parameters = { :name => name.to_s }
          parameters[:filename] = part.filename if part.filename
          parameters = parameters.map { |k, v| "#{k}=#{v.inspect}" }.join("; ")

          header = String.new # rubocop:disable String/EmptyLiteral
          header << "Content-Disposition: form-data; #{parameters}#{CRLF}"
          header << "Content-Type: #{part.content_type}#{CRLF}" if part.content_type
          header << CRLF

          footer = CRLF.dup

          @io = CompositeIO.new(StringIO.new(header), part, StringIO.new(footer))
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
