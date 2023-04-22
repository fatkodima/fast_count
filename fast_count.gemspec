# frozen_string_literal: true

require_relative "lib/fast_count/version"

Gem::Specification.new do |spec|
  spec.name = "fast_count"
  spec.version = FastCount::VERSION
  spec.authors = ["fatkodima", "Dale Stevens"]
  spec.email = ["fatkodima123@gmail.com"]

  spec.summary = "Quickly get a count estimation for large tables."
  spec.homepage = "https://github.com/fatkodima/fast_count"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files         = Dir["*.{md,txt}", "{lib,guides}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 6.0"
end
