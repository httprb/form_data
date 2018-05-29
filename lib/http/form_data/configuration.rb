# frozen_string_literal: true

module HTTP
  module FormData
    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configuration=(configuration)
      @configuration = configuration
    end

    def self.configure
      yield configuration
    end

    def self.reset!
       @configuration = Configuration.new
    end

    class Configuration
      attr_accessor :encoding_method

      def initialize
        @encoding_method = ::URI.method(:encode_www_form)
      end
    end
  end
end
