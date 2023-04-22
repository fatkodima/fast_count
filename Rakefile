# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"

namespace :test do
  ["postgresql", "mysql2", "sqlite3"].each do |adapter|
    Rake::TestTask.new(adapter) do |t|
      t.deps = ["set_#{adapter}_env"]
      t.libs = ["lib", "test"]
      t.test_files = FileList["test/**/*_test.rb"]
    end

    task("set_#{adapter}_env") { ENV["DATABASE_ADAPTER"] = adapter }
  end
end

RuboCop::RakeTask.new

task test: ["test:postgresql", "test:mysql2", "test:sqlite3"]
task default: [:rubocop, :test]
