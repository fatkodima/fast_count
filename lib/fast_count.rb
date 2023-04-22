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
  end
end

ActiveSupport.on_load(:active_record) do
  extend FastCount::Extensions::ModelExtension
  ActiveRecord::Relation.include(FastCount::Extensions::RelationExtension)
end
