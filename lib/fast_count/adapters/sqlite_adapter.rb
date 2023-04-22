# frozen_string_literal: true

module FastCount
  module Adapters
    # @private
    # No one should use sqlite in production and moreover with lots of data,
    # so we can just use `SELECT COUNT(*)`. Support for it is technically not needed,
    # but was added for convenience in development.
    #
    class SqliteAdapter < BaseAdapter
      def fast_count(table_name, _threshold)
        @connection.select_value("SELECT COUNT(*) FROM #{@connection.quote_table_name(table_name)}")
      end

      def estimated_count(sql)
        @connection.select_value("SELECT COUNT(*) FROM (#{sql})")
      end
    end
  end
end
