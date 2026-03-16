# frozen_string_literal: true

require "simplecov"

SimpleCov.start do
  add_filter "/test/"
  enable_coverage :branch
  minimum_coverage line: 100, branch: 100
end

require "minitest/autorun"
require "json"
require "http/form_data"

module FixturesHelper
  def fixture(filename)
    fixtures_root.join(filename)
  end

  def fixtures_root
    Pathname.new(__dir__).join("fixtures").realpath
  end
end
