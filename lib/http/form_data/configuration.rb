# frozen_string_literal: true

module HTTP
  module FormData
    # Configuration to adapt behavior.
    class Configuration
      # Allows to override the encoding method.
      # By default, ::URI.encode_www_form will be used.
      # If overriden, this variable should be set to a `Proc` which will
      # receive a single parameter responding to `#to_h` and will return
      # a string corresponding to the encoded data.
      attr_accessor :encoding_method

      def initialize
        @encoding_method = ::URI.method(:encode_www_form)
      end
    end
  end
end
