# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in fast_count.gemspec
gemspec

gem "rake", "~> 13.0"
gem "minitest", "~> 5.0"
gem "rubocop", "< 2"
gem "rubocop-minitest"

gem "pg"
gem "mysql2"
gem "sqlite3"

if defined?(@ar_gem_requirement)
  gem "activerecord", @ar_gem_requirement
else
  gem "activerecord" # latest
end
