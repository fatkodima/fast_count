# frozen_string_literal: true

module FastCount
  # @private
  module Utils
    def self.adapter_name(connection)
      case connection.adapter_name
      when /postg/i # PostgreSQL, PostGIS
        :postgresql
      end
    end
  end
end
