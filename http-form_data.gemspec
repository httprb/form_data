# frozen_string_literal: true

require_relative "lib/http/form_data/version"

Gem::Specification.new do |spec|
  spec.name          = "http-form_data"
  spec.version       = HTTP::FormData::VERSION
  spec.authors       = ["Aleksey V Zapparov"]
  spec.email         = ["ixti@member.fsf.org"]

  spec.summary       = "Build form data request bodies"
  spec.homepage      = "https://github.com/httprb/form_data"
  spec.license       = "MIT"

  spec.description   = <<~DESCRIPTION.strip.gsub(/\s+/, " ")
    Utility-belt to build form data request bodies.
    Provides support for `application/x-www-form-urlencoded` and
    `multipart/form-data` types.
  DESCRIPTION

  spec.metadata["homepage_uri"]          = spec.homepage
  spec.metadata["source_code_uri"]       = "#{spec.homepage}/tree/v#{spec.version}"
  spec.metadata["bug_tracker_uri"]       = "#{spec.homepage}/issues"
  spec.metadata["changelog_uri"]         = "#{spec.homepage}/blob/v#{spec.version}/CHANGELOG.md"
  spec.metadata["documentation_uri"]     = "https://www.rubydoc.info/gems/http-form_data/#{spec.version}"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    extras = %w[CHANGELOG.md LICENSE.txt README.md] << File.basename(__FILE__)

    ls.readlines("\x0", chomp: true).select do |f|
      f.start_with?("lib/", "sig/http/") || extras.include?(f)
    end
  end

  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.2"
end
