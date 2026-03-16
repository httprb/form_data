# frozen_string_literal: true

source "https://rubygems.org"

gem "rake"

group :test do
  gem "rspec", "~> 3.10"

  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rake"
  gem "rubocop-rspec"

  gem "simplecov",      :require => false
  gem "simplecov-lcov", :require => false
end

group :doc do
  gem "redcarpet", :platform => :mri
  gem "yard"
end

# Specify your gem's dependencies in form_data.gemspec
gemspec
