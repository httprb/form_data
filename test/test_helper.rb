# frozen_string_literal: true

unless ENV["MUTANT"] || ENV["NOCOV"]
  require "simplecov"

  SimpleCov.start do
    add_filter "/test/"
    enable_coverage :branch
    minimum_coverage line: 100, branch: 100
  end
end

require "minitest/autorun"
require "json"
require "http/form_data"

# No-op for mutant cover declarations when mutant is not loaded
Minitest::Test.extend(Module.new { def cover(*); end }) unless Minitest::Test.respond_to?(:cover)

module FixturesHelper
  def fixture(filename)
    fixtures_root.join(filename)
  end

  def fixtures_root
    Pathname.new(__dir__).join("fixtures").realpath
  end
end
