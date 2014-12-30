source "https://rubygems.org"

gem "rake"

group :development do
  gem "pry"
  gem "guard-rspec", :require => false
end

group :test do
  gem "backports"
  gem "coveralls"
  gem "rspec",      "~> 3.1"
  gem "simplecov",  ">= 0.9"

  platforms :ruby_19, :ruby_20, :ruby_21, :ruby_22 do
    gem "rubocop",  "~> 0.28.0"
  end
end

group :doc do
  gem "yard"
  gem "redcarpet"
end

# Specify your gem's dependencies in form_data.gemspec
gemspec
