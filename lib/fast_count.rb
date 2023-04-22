# frozen_string_literal: true

require "active_record"

require_relative "fast_count/utils"
require_relative "fast_count/adapters"
require_relative "fast_count/extensions"
require_relative "fast_count/version"

module FastCount
  class << self
    def install(connection: ActiveRecord::Base.connection)
      adapter = Adapters.for_connection(connection)
      adapter.install
    end

    def uninstall(connection: ActiveRecord::Base.connection)
      adapter = Adapters.for_connection(connection)
      adapter.uninstall
    end

    # Determines for how large tables this gem should get the exact row count using SELECT COUNT.
    # If the approximate row count is smaller than this value, SELECT COUNT will be used,
    # otherwise the approximate count will be used.
    attr_accessor :threshold
  end

  self.threshold = 100_000
end

ActiveSupport.on_load(:active_record) do
  extend FastCount::Extensions::ModelExtension
  ActiveRecord::Relation.include(FastCount::Extensions::RelationExtension)
end
