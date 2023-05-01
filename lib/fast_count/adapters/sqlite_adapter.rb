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

      def fast_distinct_count(table_name, column_name)
        @connection.select_value(<<~SQL)
          SELECT COUNT(*) FROM (
            SELECT DISTINCT #{@connection.quote_column_name(column_name)} FROM #{@connection.quote_table_name(table_name)}
          ) AS tmp
        SQL
      end
    end
  end
end
