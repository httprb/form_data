source "https://rubygems.org"

group :development do
  gem "pry"
  gem "guard-rspec", :require => false
end

group :test do
  gem "backports"
  gem "coveralls"
  gem "rspec",      "~> 3.1"
  gem "rubocop",    "~> 0.28.0", :platforms => [:ruby_19, :ruby_20, :ruby_21]
  gem "simplecov",  ">= 0.9"
end

group :doc do
  gem "yard"
  gem "redcarpet"
end

# Specify your gem"s dependencies in form_data.gemspec
gemspec
