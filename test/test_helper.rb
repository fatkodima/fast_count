# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "fast_count"

require "pg"
require "mysql2"
require "sqlite3"

require "minitest/autorun"

adapter = ENV.fetch("DATABASE_ADAPTER")
puts "Using #{adapter}"

database_yml = File.expand_path("support/database.yml", __dir__)
ActiveRecord::Base.configurations = YAML.load_file(database_yml)

ActiveRecord::Base.establish_connection(adapter.to_sym)

if ENV["VERBOSE"]
  ActiveRecord::Base.logger = ActiveSupport::Logger.new($stdout)
else
  ActiveRecord::Base.logger = ActiveSupport::Logger.new("debug.log", 1, 100 * 1024 * 1024) # 100 mb
  ActiveRecord::Migration.verbose = false
end

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name
    t.boolean :admin, null: false, default: false
    t.integer :company_id
  end
end

class User < ActiveRecord::Base
end

class Project < ActiveRecord::Base
end
