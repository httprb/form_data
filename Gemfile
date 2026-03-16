# frozen_string_literal: true

source "https://rubygems.org"

gem "rake"

group :test do
  gem "minitest", "~> 6.0"

  gem "rubocop"
  gem "rubocop-minitest"
  gem "rubocop-performance"
  gem "rubocop-rake"

  gem "simplecov", require: false

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
