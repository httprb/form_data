source "https://rubygems.org"

gem "rake"

group :development do
  gem "pry"
  gem "guard"
  gem "guard-rspec", :require => false
end

group :test do
  gem "coveralls"
  gem "rspec",      "~> 3.1"
  gem "simplecov",  ">= 0.9"
  gem "rubocop",    "~> 0.28.0"
end

group :doc do
  gem "yard"
  gem "redcarpet"
end

# Specify your gem's dependencies in form_data.gemspec
gemspec
