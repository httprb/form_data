# frozen_string_literal: true

source "https://rubygems.org"

gem "rake"

group :development do
  # Duel requires Ruby 3.4 or later
  gem "duel", ">= 0.1.1" if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4")
  gem "stackprof", platforms: :mri
end

group :test do
  gem "minitest", "~> 6.0"

  gem "rubocop"
  gem "rubocop-minitest"
  gem "rubocop-performance"
  gem "rubocop-rake"

  gem "simplecov", ">= 1", require: false

  gem "mutant-minitest"

  gem "yardstick"
end

group :sig do
  gem "steep"
end

group :doc do
  gem "kramdown"
  gem "yard"
end

# Specify your gem's dependencies in form_data.gemspec
gemspec
