# frozen_string_literal: true

require_relative "adapters/base_adapter"
require_relative "adapters/postgresql_adapter"
require_relative "adapters/mysql_adapter"
require_relative "adapters/sqlite_adapter"

module FastCount
  # @private
  module Adapters
    def self.for_connection(connection)
      adapter_name = Utils.adapter_name(connection)
      lookup(adapter_name).new(connection)
    end

    def self.lookup(name)
      const_get("#{name.to_s.camelize}Adapter")
    end
  end
end
